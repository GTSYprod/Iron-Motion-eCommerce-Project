// ***********************************************
// Custom commands for Iron & Motion E-commerce Tests
// ***********************************************

// Login command
Cypress.Commands.add('login', (email, password) => {
  cy.visit('/users/sign_in')
  cy.get('input[name="user[email]"]').type(email)
  cy.get('input[name="user[password]"]').type(password)
  cy.get('input[type="submit"]').click()
})

// Logout command
Cypress.Commands.add('logout', () => {
  cy.get('a[data-turbo-method="delete"]').click()
})

// Create user command
Cypress.Commands.add('createUser', (userData) => {
  cy.visit('/users/sign_up')
  cy.get('input[name="user[first_name]"]').type(userData.firstName)
  cy.get('input[name="user[last_name]"]').type(userData.lastName)
  cy.get('input[name="user[email]"]').type(userData.email)
  cy.get('input[name="user[password]"]').type(userData.password)
  cy.get('input[name="user[password_confirmation]"]').type(userData.password)
  cy.get('input[type="submit"]').click()
})

// Add product to cart
Cypress.Commands.add('addProductToCart', (productId) => {
  cy.visit(`/products/${productId}`)
  cy.get('form[action="/shopping_cart/add_item"]').within(() => {
    cy.get('input[name="product_id"]').should('have.value', productId.toString())
    cy.get('input[type="submit"]').click()
  })
})

// Clear cart
Cypress.Commands.add('clearCart', () => {
  cy.visit('/shopping_cart')
  cy.get('form[action="/shopping_cart/clear"]').then($form => {
    if ($form.length) {
      cy.wrap($form).find('input[type="submit"]').click()
    }
  })
})
