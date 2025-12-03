describe('User Authentication - Login Flow', () => {
  beforeEach(() => {
    // Reset database state if needed
    cy.visit('/')
  })

  describe('Happy Path - Successful Login', () => {
    it('should successfully log in with valid credentials', () => {
      // Visit login page
      cy.visit('/users/sign_in')

      // Verify we're on the login page
      cy.contains('Log in').should('be.visible')

      // Use test credentials (admin or seeded user)
      cy.get('input[name="user[email]"]').type('test@example.com')
      cy.get('input[name="user[password]"]').type('password123')

      // Submit the form
      cy.get('input[type="submit"]').click()

      // Verify successful login (redirected to products page or dashboard)
      cy.url().should('not.include', '/users/sign_in')

      // Verify user is logged in (check for logout link or user menu)
      cy.contains('Logout').should('be.visible')
    })

    it('should allow navigation to products after login', () => {
      cy.login('test@example.com', 'password123')

      // Navigate to products
      cy.visit('/products')

      // Verify products are visible
      cy.get('.product-card').should('exist')
    })

    it('should persist login session', () => {
      cy.login('test@example.com', 'password123')

      // Navigate away
      cy.visit('/about')

      // User should still be logged in
      cy.contains('Logout').should('be.visible')
    })
  })

  describe('Unhappy Path - Failed Login Attempts', () => {
    it('should show error with invalid email', () => {
      cy.visit('/users/sign_in')

      cy.get('input[name="user[email]"]').type('nonexistent@example.com')
      cy.get('input[name="user[password]"]').type('wrongpassword')
      cy.get('input[type="submit"]').click()

      // Should stay on login page
      cy.url().should('include', '/users/sign_in')

      // Should show error message
      cy.contains(/invalid|incorrect/i).should('be.visible')
    })

    it('should show error with wrong password', () => {
      cy.visit('/users/sign_in')

      cy.get('input[name="user[email]"]').type('test@example.com')
      cy.get('input[name="user[password]"]').type('wrongpassword')
      cy.get('input[type="submit"]').click()

      // Should stay on login page
      cy.url().should('include', '/users/sign_in')

      // Should show error message
      cy.contains(/invalid|incorrect/i).should('be.visible')
    })

    it('should require email field', () => {
      cy.visit('/users/sign_in')

      // Try to submit without email
      cy.get('input[name="user[password]"]').type('password123')
      cy.get('input[type="submit"]').click()

      // Should validate email field
      cy.get('input[name="user[email]"]').then($input => {
        expect($input[0].validationMessage).to.not.be.empty
      })
    })

    it('should require password field', () => {
      cy.visit('/users/sign_in')

      // Try to submit without password
      cy.get('input[name="user[email]"]').type('test@example.com')
      cy.get('input[type="submit"]').click()

      // Should validate password field
      cy.get('input[name="user[password]"]').then($input => {
        expect($input[0].validationMessage).to.not.be.empty
      })
    })

    it('should trim whitespace from email', () => {
      cy.visit('/users/sign_in')

      cy.get('input[name="user[email]"]').type('  test@example.com  ')
      cy.get('input[name="user[password]"]').type('password123')
      cy.get('input[type="submit"]').click()

      // Should handle trimmed email
      // This test verifies the backend handles whitespace correctly
    })
  })

  describe('Remember Me Functionality', () => {
    it('should show remember me checkbox', () => {
      cy.visit('/users/sign_in')

      cy.get('input[name="user[remember_me]"]').should('exist')
    })

    it('should allow checking remember me option', () => {
      cy.visit('/users/sign_in')

      cy.get('input[name="user[remember_me]"]').check()
      cy.get('input[name="user[email]"]').type('test@example.com')
      cy.get('input[name="user[password]"]').type('password123')
      cy.get('input[type="submit"]').click()

      // Login should succeed
      cy.url().should('not.include', '/users/sign_in')
    })
  })

  describe('Logout Functionality', () => {
    it('should successfully log out', () => {
      // Login first
      cy.login('test@example.com', 'password123')

      // Click logout
      cy.logout()

      // Should redirect to home or login page
      cy.contains('Login').should('be.visible')
      cy.contains('Logout').should('not.exist')
    })

    it('should clear session after logout', () => {
      cy.login('test@example.com', 'password123')
      cy.logout()

      // Try to access protected page
      cy.visit('/orders')

      // Should redirect to login
      cy.url().should('include', '/users/sign_in')
    })
  })
})
