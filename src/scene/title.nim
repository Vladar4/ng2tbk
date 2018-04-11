import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    input,
    scene,
    settings,
    textgraphic,
    tween,
    types,
  ],
  ../data,
  ../character


type
  TitleScene = ref object of Scene
    titleText: TextGraphic
    title: Entity
    player: Character


proc init*(scene: TitleScene) =
  init Scene scene

  # title
  scene.titleText = newTextGraphic defaultFont
  scene.titleText.setText GameTitle
  scene.title = newEntity()
  scene.title.graphic = scene.titleText
  scene.title.centrify HAlign.center, VAlign.top
  scene.title.pos = (GameDim.w div 2, 32)
  scene.add scene.title

  # player
  scene.player = newCharacter gfxData["player"]
  scene.player.control = ckPlayer1
  scene.player.pos = GameDim / (3, 2)
  scene.add scene.player

  var p2 = newCharacter(gfxData["player"], true)
  p2.control = ckPlayer2
  p2.pos = GameDim / 2
  scene.add p2


proc free*(scene: TitleScene) =
  discard


method show*(scene: TitleScene) =
  discard


proc newTitleScene*(): TitleScene =
  new result, free
  init result


method update*(scene: TitleScene, elapsed: float) =
  scene.updateScene elapsed
  if ScancodeF10.pressed:
    colliderOutline = not colliderOutline

