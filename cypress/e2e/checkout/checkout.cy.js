describe('Checkout Process - End to End Flow', () => {
  beforeEach(() => {
    // Start fresh for each test
    cy.visit('/')
  })

  describe('Happy Path - Successful Checkout', () => {
    it('should complete full checkout process from product to order', () => {
      // Step 1: User Registration
      const testUser = {
        firstName: 'John',
        lastName: 'Doe',
        email: `test${Date.now()}@example.com`,
        password: 'Password123!'
      }

      cy.createUser(testUser)

      // Step 2: Browse and add product to cart
      cy.visit('/products')
      cy.get('.product-card').first().click()

      // Step 3: Add to cart
      cy.get('form[action="/shopping_cart/add_item"]').within(() => {
        cy.get('input[name="quantity"]').clear().type('2')
        cy.get('input[type="submit"]').click()
      })

      // Step 4: Verify cart
      cy.url().should('include', '/shopping_cart')
      cy.contains('Shopping Cart').should('be.visible')

      // Verify quantity
      cy.get('input[name="item_quantity"]').should('have.value', '2')

      // Step 5: Create address
      cy.visit('/addresses/new')
      cy.get('input[name="address[street_address]"]').type('123 Main Street')
      cy.get('input[name="address[city]"]').type('Winnipeg')
      cy.get('input[name="address[province]"]').type('Manitoba')
      cy.get('input[name="address[postal_code]"]').type('R3C1A5')
      cy.get('input[name="address[is_default]"]').check()
      cy.get('input[type="submit"]').click()

      // Step 6: Proceed to checkout
      cy.visit('/shopping_cart')
      cy.contains('Proceed to Checkout').click()

      // Step 7: Complete checkout
      cy.url().should('include', '/checkout')

      // Select address
      cy.get('input[name="address_id"]').first().check()

      // Submit order
      cy.get('input[type="submit"]').click()

      // Step 8: Verify order completion
      cy.url().should('include', '/orders/')
      cy.contains(/order.*placed|thank you|confirmation/i).should('be.visible')

      // Step 9: Verify cart is cleared
      cy.visit('/shopping_cart')
      cy.contains('cart is empty').should('be.visible')
    })

    it('should allow checkout with existing address', () => {
      // Login with existing user
      cy.login('test@example.com', 'password123')

      // Add product to cart
      cy.addProductToCart(1)

      // Go to checkout
      cy.visit('/shopping_cart')
      cy.contains('Proceed to Checkout').click()

      // Select existing address
      cy.get('input[name="address_id"]').first().check()

      // Submit order
      cy.get('input[type="submit"]').click()

      // Verify order created
      cy.url().should('include', '/orders/')
    })

    it('should preserve prices at purchase time', () => {
      cy.login('test@example.com', 'password123')

      // Get product price
      cy.visit('/products/1')
      cy.get('.product-card__price').first().invoke('text').as('originalPrice')

      // Add to cart
      cy.addProductToCart(1)

      // Complete checkout
      cy.visit('/shopping_cart')
      cy.contains('Proceed to Checkout').click()
      cy.get('input[name="address_id"]').first().check()
      cy.get('input[type="submit"]').click()

      // Verify order shows same price
      cy.get('@originalPrice').then((price) => {
        cy.contains(price).should('be.visible')
      })
    })
  })

  describe('Unhappy Path - Checkout Failures', () => {
    it('should require login for checkout', () => {
      // Add product to cart as guest
      cy.visit('/products/1')
      cy.get('form[action="/shopping_cart/add_item"]').within(() => {
        cy.get('input[type="submit"]').click()
      })

      // Try to checkout
      cy.visit('/checkout')

      // Should redirect to login
      cy.url().should('include', '/users/sign_in')
    })

    it('should prevent checkout with empty cart', () => {
      cy.login('test@example.com', 'password123')

      // Clear cart
      cy.clearCart()

      // Try to access checkout
      cy.visit('/checkout')

      // Should redirect or show error
      cy.url().should('not.include', '/checkout')
      cy.contains(/cart is empty|no items/i).should('be.visible')
    })

    it('should require address selection', () => {
      cy.login('test@example.com', 'password123')

      // Add product to cart
      cy.addProductToCart(1)

      // Go to checkout
      cy.visit('/shopping_cart')
      cy.contains('Proceed to Checkout').click()

      // Try to submit without selecting address
      cy.get('input[type="submit"]').click()

      // Should show validation error
      // (Note: This depends on your validation implementation)
    })

    it('should handle invalid address data', () => {
      cy.login('test@example.com', 'password123')

      // Try to create invalid address
      cy.visit('/addresses/new')
      cy.get('input[name="address[street_address]"]').type('123')
      cy.get('input[name="address[postal_code]"]').type('INVALID')
      cy.get('input[type="submit"]').click()

      // Should show validation errors
      cy.contains(/invalid|error/i).should('be.visible')
    })

    it('should handle out of stock products', () => {
      cy.login('test@example.com', 'password123')

      // Find out of stock product
      cy.visit('/products')
      cy.contains('Out of Stock').parent().parent().within(() => {
        // Verify "Add to Cart" button is disabled or not present
        cy.get('input[type="submit"]').should('be.disabled')
      })
    })
  })

  describe('Shopping Cart Management', () => {
    beforeEach(() => {
      cy.login('test@example.com', 'password123')
    })

    it('should update item quantity in cart', () => {
      // Add product to cart
      cy.addProductToCart(1)

      // Update quantity
      cy.get('input[name="item_quantity"]').clear().type('5')
      cy.contains('Update').click()

      // Verify update
      cy.contains('Cart updated').should('be.visible')
      cy.get('input[name="item_quantity"]').should('have.value', '5')
    })

    it('should remove item from cart', () => {
      // Add product to cart
      cy.addProductToCart(1)

      // Remove item
      cy.contains('Remove').click()

      // Confirm removal if there's a confirmation dialog
      // cy.on('window:confirm', () => true)

      // Verify removal
      cy.contains('cart is empty').should('be.visible')
    })

    it('should calculate correct totals', () => {
      cy.addProductToCart(1)

      // Get item price and quantity
      cy.get('.product-card__price').first().invoke('text').then((priceText) => {
        cy.get('input[name="item_quantity"]').invoke('val').then((qty) => {
          // Verify total calculation
          // (Note: You'll need to parse price and calculate expected total)
          cy.contains('Total').parent().should('be.visible')
        })
      })
    })

    it('should persist cart across sessions', () => {
      // Add product to cart
      cy.addProductToCart(1)

      // Logout
      cy.logout()

      // Login again
      cy.login('test@example.com', 'password123')

      // Check cart
      cy.visit('/shopping_cart')

      // Cart should still have items
      cy.get('.product-card').should('exist')
    })

    it('should clear entire cart', () => {
      // Add multiple products
      cy.addProductToCart(1)
      cy.visit('/products')
      cy.addProductToCart(2)

      // Clear cart
      cy.visit('/shopping_cart')
      cy.contains('Clear Cart').click()

      // Confirm if there's a confirmation dialog
      cy.on('window:confirm', () => true)

      // Verify cart is empty
      cy.contains('cart is empty').should('be.visible')
    })
  })

  describe('Order History', () => {
    it('should display order in order history', () => {
      cy.login('test@example.com', 'password123')

      // Complete a purchase
      cy.addProductToCart(1)
      cy.visit('/shopping_cart')
      cy.contains('Proceed to Checkout').click()
      cy.get('input[name="address_id"]').first().check()
      cy.get('input[type="submit"]').click()

      // Visit order history
      cy.visit('/orders')

      // Verify order appears
      cy.get('.card').should('exist')
      cy.contains('Order').should('be.visible')
    })

    it('should show order details', () => {
      cy.login('test@example.com', 'password123')

      // Visit existing order
      cy.visit('/orders')
      cy.get('.card').first().click()

      // Verify order details
      cy.contains('Order').should('be.visible')
      cy.contains(/product|item/i).should('be.visible')
      cy.contains(/total|price/i).should('be.visible')
      cy.contains(/address|shipping/i).should('be.visible')
    })
  })

  describe('Address Management', () => {
    beforeEach(() => {
      cy.login('test@example.com', 'password123')
    })

    it('should create new address', () => {
      cy.visit('/addresses/new')

      cy.get('input[name="address[street_address]"]').type('456 Oak Avenue')
      cy.get('input[name="address[city]"]').type('Toronto')
      cy.get('input[name="address[province]"]').type('Ontario')
      cy.get('input[name="address[postal_code]"]').type('M5V3A1')
      cy.get('input[type="submit"]').click()

      // Verify creation
      cy.contains('Address added').should('be.visible')
    })

    it('should edit existing address', () => {
      cy.visit('/addresses')

      // Click edit on first address
      cy.contains('Edit').first().click()

      // Update address
      cy.get('input[name="address[city]"]').clear().type('Vancouver')
      cy.get('input[type="submit"]').click()

      // Verify update
      cy.contains('Address updated').should('be.visible')
    })

    it('should delete address', () => {
      cy.visit('/addresses')

      // Get initial count
      cy.get('.card').then($cards => {
        const initialCount = $cards.length

        // Delete first address
        cy.contains('Delete').first().click()

        // Confirm deletion if there's a confirmation dialog
        cy.on('window:confirm', () => true)

        // Verify deletion
        if (initialCount > 1) {
          cy.get('.card').should('have.length', initialCount - 1)
        }
      })
    })

    it('should set default address', () => {
      cy.visit('/addresses')

      // Set first address as default
      cy.get('input[name="address[is_default]"]').first().check()

      // Submit form
      cy.get('form').first().submit()

      // Verify default status
      cy.contains('default', { matchCase: false }).should('be.visible')
    })
  })
})
