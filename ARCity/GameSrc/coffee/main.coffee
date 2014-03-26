showingInfo = false

arel.sceneReady ->
    man = arel.Scene.getObject 'man'
    man.setScale new arel.Vector3D 2, 2, 2
    man.setTitle "Karel"
    arel.Events.setListener man, (obj, type, params) -> objectClickHandler obj, type, params
    return


objectClickHandler = (obj, type, params) ->

    if type and type is arel.Events.Object.ONTOUCHSTARTED
        if showingInfo
            document.getElementById('info').style.display = 'none'
            document.getElementById('name').innerHTML = obj.title
            showingInfo = false
        else
            document.getElementById('info').style.display = 'block'
            document.getElementById('name').innerHTML = obj.title
            showingInfo = true
    return
