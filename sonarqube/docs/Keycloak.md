# SAML Keycloak integration for Sonarqube
[Upstream Sonarqube Docs](https://docs.sonarqube.org/latest/instance-administration/delegated-auth/#header-4)
## In the Keycloak server, create a new SAML client
Create a new client

1. "Client ID" is something like "sonarqube"
2. "Client Protocol" must be set to "saml"
3. "Client SAML Endpoint" can be left empty

Configure the new client

1. in Settings
  1. Set"Client Signature Required" to OFF
  2. Set "Valid Redirect URIs" to "/oauth2/callback/*, E.G https://sonarqube.mycompany.com/oauth2/callback/saml
2. in Client Scopes > Default Client Scopes , remove "role_list" from "Assigned Default Client Scopes" (to prevent the error com.onelogin.saml2.exception.ValidationError: Found an Attribute element with duplicated Name during authentication)
3. In Mappers create a mapper for each user attribute (Note that values provided below for Name, SAML Attribute Name, Role Attribute Name are only example values):
  1. Create a mapper for the login:
  2. Name: Login
  3. Mapper Type: User Property
  4. Property: Username (Note that the login should not contain any special characters other than .-_@ to meet SonarQube restrictions.)
  5. SAML Attribute Name: login
  6. Create a mapper for the name:
  7. Name: Name
  8. Mapper Type: User Property
  9. User Attribute: Username (It can also be another attribute you would previously have specified for the users)
  10. SAML Attribute Name: name
  11. (Optional) Create a mapper for the email:
  12. Name: Email
  13. Mapper Type: User Property
  14. Property: Email
  15. SAML Attribute Name: email
  16. (Optional) Create a mapper for the groups (If you rely on a list of roles defined in "Roles" of the Realm (not in "Roles" of the client)):
  17. Name: Groups
  18. Mapper Type: Role list
  19. Role Attribute Name: groups
  20. Single Role Attribute: ON
  21. If you rely on a list of groups defined in "Groups":
  22. Name: Groups
  23. Mapper Type: Group list
  24. Role Attribute Name: groups
  25. Single Role Attribute: ON
  26. Full Group Path: OFF

## In SonarQube, Configure SAML authentication
Go to Administration > Configuration > General Settings > Security > SAML
* Enabled should be set to true
* Application ID is the value of the "Client ID" you set in Keycloak (for example "sonarqube")
* Provider ID is the value of the "EntityDescriptor" > "entityID" attribute in the XML configuration file (for example "http://keycloak:8080/auth/realms/sonarqube" where sonarqube is the name of the realm)
* SAML login url is the value of "SingleSignOnService" > "Location" attribute in the XML configuration file (for example "http://keycloak:8080/auth/realms/sonarqube/protocol/saml")
* Provider certificate is the value you get from Realm Settings -> Keys -> click on the Certificate button
* SAML user login attribute is the value set in the login mapper in "SAML Attribute Name"
* SAML user name attribute is the value set in the name mapper in "SAML Attribute Name"
* (Optional) SAML user email attribute is the value set in the email mapper in "SAML Attribute Name"
* (Optional) SAML group attribute is the value set in the groups mapper in "Role/Group Attribute Name"
In the login form, the new button "Log in with SAML" allows users to connect with their SAML account.

## Helm Values Config example:

Within BigBang:
```yaml
addons:
  sonarqube:
    sso:
      enabled: true
      client_id: platform1_###
      client_secret: ###########
      # Label is interchangeable with "provider_name"
      # -- SonarQube SSO login button label
      #provider_name: "P1 SSO"
      label: "P1 SSO"
      # -- SonarQube plaintext SAML sso certificate.
      certificate: "M#######...="
      # Other default options from BigBang
      # -- SonarQube login sso attribute.
      login: login
      # -- SonarQube name sso attribute.
      name: name
      # -- SonarQube email sso attribute.
      email: email
      # -- (optional) SonarQube group sso attribute.
      group: group
```

Within Sonarqube package:
```yaml
sonarProperties:
  sonar.forceAuthentication: true
# SAML SSO config
  sonar.core.serverBaseURL: https://sonarqube.bigbang.dev
  sonar.auth.saml.enabled: true
  sonar.auth.saml.applicationId: platform1_a8604cc9-f5e9-4656-802d-d05624370245_bb8-saml-sonarqube
  sonar.auth.saml.providerName: P1 SSO
  sonar.auth.saml.providerId: https://login.dsop.io/auth/realms/baby-yoda
  sonar.auth.saml.loginUrl: https://login.dsop.io/auth/realms/baby-yoda/protocol/saml
  sonar.auth.saml.certificate.secured: MILicoTCCAYkCBgFyLIEqUjaNbg...
  sonar.auth.saml.user.login: login
  sonar.auth.saml.user.name: name
  sonar.auth.saml.user.email: email
  sonar.auth.saml.group.name: group
```

# OIDC Keycloak integration for Sonarqube

1. Login to SonarQube with default admin credentials username: admin password: admin
2. In Adminstration->General
   set Server base URL to Sonarqube URL
   (for ex: https:/sonarqube.dsop.io) without a trailing /
3. On a different tab on the browser, login to  keycloak realm
   - From Clients choose the sonarqube client and note the Client id
     - Set Root URL to empty string
     - Set Valid Redirect URI to
        ```https://<sonarqube url>/*```
        (for ex: https://sonarqube.dsop.io/*)
     - Set Base URI to Sonarqube URL
       (for ex: https://sonarqube.dsop.io) without a trailing /
   - On Clients-<Sonarqube Client>->Credentials regenerate the secret and note it down
   - On Clients-<Sonarqube Client>->ClientScopes->Sonarqube->Mappers
     - Click Add Builtin and add "groups" scope
   - On Users, click "Add User" and enter
     - Username - <username of the admin user>
     - email - must have @admin.mil id
     - First name
     - Last name
     - Email Verified - On
     - Save
   - On Users, on the Credentials tab and set password
   - On Users, on the Groups tab and join Impact Level2 Authorized and System Admins IL2
4. In Administration-> Security Set OpenID Connect to enabled
   - Issuer URI to https://keycloak.fences.dsop.io/auth/realms/baby-yoda
   - ClientId noted from keycloak above
   - ClientSecret regenerated from keycloak above
   - Scopes - openid Sonarqube
5. Logout of sonarqube and log back in with the username created above by clicking on oidc login
6. Logout of sonarqube and log back in with the username admin and password admin
7. Go to Administration->Security->Users and add username created above to sonar-admin group
8. Go to Administration->Security->Users and delete admin user
9. Logout of SonarQube and login with username and password created in keycloak
