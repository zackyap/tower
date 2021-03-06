require '../../config'

view = null
user = null

describe 'Tower.View.Form', ->
  beforeEach ->
    view = new Tower.View
    
  describe 'form', ->
    beforeEach ->
      user = new App.User(id: 1, firstName: "Lance")
      
    test '#formFor()', ->
      template = ->
        formFor()
      
      view.render template: template, (error, result) ->
        assert.equal result, '''
<form action="/" id="model-form" role="form" novalidate="true" data-method="post" method="post">
  <input type="hidden" name="_method" value="post" />
</form>

'''
    test '#formFor(user)', ->
      template = ->
        formFor @user, (form) ->
          form.fieldset (fields) ->
            fields.field "firstName"
      
      view.render template: template, locals: user: user, (error, result) ->
        throw error if error
        assert.equal result, '''
<form action="/users/1" id="user-form" role="form" novalidate="true" data-method="put" method="post">
  <input type="hidden" name="_method" value="put" />
  <fieldset>
    <ol class="fields">
      <li class="field string optional" id="user-firstName-field">
        <label for="user-firstName-input" class="label">
          <span>FirstName</span>
          <abbr title="Optional" class="optional">
            
          </abbr>
        </label>
        <input type="text" id="user-firstName-input" name="user[firstName]" class="string first-name optional input" aria-required="false" />
      </li>
    </ol>
  </fieldset>
</form>

'''
    test '#formFor(user) with errors', ->
      user.set "firstName", null
      user.validate()
      assert.deepEqual user.errors, { firstName: [ 'firstName can\'t be blank' ] }
      template = ->
        formFor @user, (form) ->
          form.fieldset (fields) ->
            fields.field "firstName"

      view.render template: template, locals: user: user, (error, result) ->
        throw error if error
        assert.equal result, '''
<form action="/users/1" id="user-form" role="form" novalidate="true" data-method="put" method="post">
  <input type="hidden" name="_method" value="put" />
  <fieldset>
    <ol class="fields">
      <li class="field string optional" id="user-firstName-field">
        <label for="user-firstName-input" class="label">
          <span>FirstName</span>
          <abbr title="Optional" class="optional">
            
          </abbr>
        </label>
        <input type="text" id="user-firstName-input" name="user[firstName]" class="string first-name optional input" aria-required="false" />
      </li>
    </ol>
  </fieldset>
</form>

'''
