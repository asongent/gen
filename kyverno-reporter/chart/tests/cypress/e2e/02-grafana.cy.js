// Validates panel data should not be zero
Cypress.Commands.add('panelnotzero', (name) => {
  cy.get('[data-testid="data-testid Panel header ' + name + '"]')
    .contains(/^[1-9][0-9]*$/)
})

// Log in
before (function() {
  cy.visit(Cypress.env('grafana_url'))
  cy.performGrafanaLogin(Cypress.env('grafana_user'), Cypress.env('grafana_pass'))
})

// Save cookies so we don't have to log in again
beforeEach(function () {
  cy.visit(`${Cypress.env('grafana_url')}/dashboards`)
})

describe('Validate Grafana Dashboards', {
  retries: {
    runMode: 4,
  }
}, () => {
  if (Cypress.env("check_datasource")) {
    it('Validate Cluster Policy Report Details Dashboard', () => {
      cy.loadGrafanaDashboard("ClusterPolicyReport Details")
      cy.panelnotzero('Policy Pass Status')
      cy.panelnotzero('Policy Fail Status')
    })
    it('Validate Policy Report Details Dashboard', () => {
      cy.loadGrafanaDashboard("PolicyReport Details")
      cy.panelnotzero('Policy Pass Status')
      cy.panelnotzero('Policy Fail Status')
    })
    it('Validate Policy Reports Dashboard', () => {
      cy.loadGrafanaDashboard("PolicyReports")
      cy.panelnotzero('Failing ClusterPolicies')
    })
  }
})

// Clear cookies to force login again
after(() => {
  cy.clearAllUserData()
})