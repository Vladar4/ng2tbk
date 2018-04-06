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
  ../data


type
  TitleScene = ref object of Scene
    titleText: TextGraphic
    title: Entity


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


proc free*(scene: TitleScene) =
  discard


method show*(scene: TitleScene) =
  discard


proc newTitleScene*(): TitleScene =
  new result, free
  init result


method event*(scene: TitleScene, e: Event) =
  if e.kind in {KeyDown, MouseButtonDown}:
    discard


method update*(scene: TitleScene, elapsed: float) =
  scene.updateScene elapsed

