Feature: Pruebas API Marvel Characters

  Background:
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/testuser/api/characters'
    * header Content-Type = 'application/json'

  Scenario: Obtener todos los personajes (con datos)
    When method get
    Then status 200
    * def count = response.length
    * assert count > 0

  Scenario: Crear personaje exitosamente
    * def uuid = java.util.UUID.randomUUID().toString()
    * def uniqueName = 'Iron Man ' + uuid
    Given request
      """
      {
        name: "#(uniqueName)",
        alterego: "Tony Stark tst",
        description: "Genius billionaire tst4",
        powers: ["Armor tst4", "Flight tst4"]
      }
      """
    When method post
    Then status 201
    And match response.alterego == "Tony Stark tst"

  Scenario: Crear personaje con nombre duplicado
    Given request { name: 'Iron Man', alterego: 'Otro', description: 'Otro', powers: ['Armor'] }
    When method post
    Then status 400
    And match response.error == 'Character name already exists'

  Scenario: Crear personaje con campos requeridos vacíos
    Given request { name: '', alterego: '', description: '', powers: [] }
    When method post
    Then status 400
    And match response.name == 'Name is required'

  Scenario: Obtener personaje por ID exitoso
    Given path '342'
    When method get
    Then status 200
    And match response.name == 'Iron Man tst'

  Scenario: Obtener personaje por ID no existe
    Given path '999'
    When method get
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Actualizar personaje exitosamente
    Given path '643'
    And request { name: 'Iron Man', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }
    When method put
    Then status 200
    And match response.description == 'Updated description'

  Scenario: Actualizar personaje no existe
    Given path '999'
    And request { name: 'Iron Man', alterego: 'Tony Stark', description: 'Updated description', powers: ['Armor', 'Flight'] }
    When method put
    Then status 404
    And match response.error == 'Character not found'

  Scenario: Eliminar personaje exitosamente
    * def uuid = java.util.UUID.randomUUID().toString()
    * def uniqueName = 'Iron Man to delete test ' + uuid
    Given request
      """
      {
        name: "#(uniqueName)",
        alterego: "Tony Stark tst",
        description: "Genius billionaire tst",
        powers: ["Armor tst", "Flight tst"]
      }
      """
    When method post
    Then status 201
    * def personajeId = response.id

    Given path personajeId
    When method delete
    Then status 204

  Scenario: Eliminar personaje no existe
    Given path '999'
    When method delete
    Then status 404
    And match response.error == 'Character not found'