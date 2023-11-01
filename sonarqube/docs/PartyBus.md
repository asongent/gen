# SonarQube configuration for PartyBus

1. Log in using default username / password
2. Navigate to Administration > Security > Users
3. Click the Cog for the Administrator user > change password > populate the old and new password, saving the new password
4. Click the admin user's profile (top right corner) > My Account > Security
5. Enter a token name > Generate, saving the token and name
6. Follow instructions for Keycloak [integration](Keycloak.md)
7. Quality Gates > Create
8. Name = "Platform One Quality Gate" > Save
9. Set as Default
10. Add Condition (for each) >  
    1.  On New Code and Overall Code
        1.  Coverage = 80
        2.  Maintainability Rating = A
        3.  Reliability Rating = A
        4.  Security Hotspots Reviewed = 0
        5.  Security Rating = A