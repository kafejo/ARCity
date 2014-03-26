requirejs.config
    baseurl: 'js'

showingInfo = false

arel.sceneReady ->
    arel.Debug.log 'Loading scene...'
    model = arel.Scene.getObject 'family_house'
    house = new Building model
    arel.Events.setListener model, (obj, type, params) -> objectClickHandler obj, type, params
    return


objectClickHandler = (obj, type, params) ->

    if type and type is arel.Events.Object.ONTOUCHSTARTED
        if showingInfo
            document.getElementById('info').style.display = 'none'
            document.getElementById('name').innerHTML = obj.title
            showingInfo = no
        else
            document.getElementById('info').style.display = 'block'
            document.getElementById('name').innerHTML = obj.title
            showingInfo = yes
    return
