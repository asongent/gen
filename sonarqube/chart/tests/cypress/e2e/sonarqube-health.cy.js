
const customTimeout = Cypress.env('timeout') ?? 10000

// needs to be fixed
Cypress.on('uncaught:exception', (err, runnable) => {
  // returning false here prevents Cypress from failing the test
  return false
})
describe('Basic Sonarqube', function() {
  it('Check Sonarqube is accessible', function() {
    cy.visit(Cypress.env('url'))
    cy.get("body").then($body => {
      if ($body.find('h1[class="maintenance-title"]').length > 0) {
        cy.visit(Cypress.env('url_setup'))
        cy.get('button[id="start-migration"]', {timeout: customTimeout}).click()
        cy.contains('Database is up-to-date', {timeout: customTimeout})
        cy.contains('SonarQube is starting', {timeout: customTimeout})
      }
    })

    //Login and wait for authentication call to complete before moving on
    cy.get('input[name="login"]').type(Cypress.env('user'))
    cy.get('input[name="password"]').type(Cypress.env('password'))
    cy.intercept('POST', '**/api/authentication/login').as('validSession')
    cy.get('button[type="submit"]').contains("Log in").click()
    cy.wait('@validSession').then((interception) => {
      expect(interception.response.statusCode).to.equal(200)
    })

    //Check to see if we end up on the screen asking us to consent and if so perform consnet
    cy.url().then((currentURL) => {
      if (currentURL.includes('plugin_risk_consent')) {
        cy.contains("I understand the risk").click()
      }
    })

    cy.scrollTo('topRight')
    cy.get('a[class="dropdown-toggle navbar-avatar"]').click()
    cy.contains("My Account").click()
    cy.contains("Security").click()
    cy.get('input[placeholder="Enter Token Name"]').type(Math.random().toString(36).substring(8))
    cy.get('#token-select-type').click()
    cy.get('#react-select-2-option-1').click()
    cy.get('button[class="button it__generate-token"]').click()
  })
})
