import
  nimgame2 / [
    assets,
    nimgame,
    entity,
    scene,
    settings,
    tween,
    types,
  ],
  ../data,
  title


type
  IntroScene = ref object of Scene
    bg: Entity


proc init*(scene: IntroScene) =
  init Scene scene
  scene.bg = newEntity()
  scene.bg.graphic = gfxData["intro"]
  scene.add scene.bg


proc free*(scene: IntroScene) =
  discard


method show*(scene: IntroScene) =
  discard


proc newIntroScene*(): IntroScene =
  new result, free
  init result


method event*(scene: IntroScene, e: Event) =
  if e.kind in {KeyDown, MouseButtonDown}:
    game.scene = titleScene


method update*(scene: IntroScene, elapsed: float) =
  scene.updateScene elapsed

