import
  nimgame2 / [
    assets,
    nimgame,
    entity,
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
  scene.player.pos = GameDim / 2
  scene.add scene.player


proc free*(scene: TitleScene) =
  discard


method show*(scene: TitleScene) =
  discard


proc newTitleScene*(): TitleScene =
  new result, free
  init result


method update*(scene: TitleScene, elapsed: float) =
  scene.updateScene elapsed

