
describe('Prometheus Targets', {
  retries: {
    runMode: 5,
  }
}, () => {
    it('Validate metrics are scraped', () => {
      cy.wait(5000)
      cy.visit(`${Cypress.env('prometheus_url')}/targets`)
      cy.validatePromTarget(Cypress.env('reporter_ns'), "(1/1 up)")
    })
})
