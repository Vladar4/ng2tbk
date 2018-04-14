import
  strutils,
  nimgame2 / [
    assets,
    entity,
    textgraphic,
    types,
  ],
  character, data


type
  LifeMeter* = ref object of Entity
    source*: Character
    mirrored*: bool


proc updateLifeMeter*(lm: LifeMeter, elapsed: float) =
  if lm.source.health < 0:
    lm.source.health = 0
  if lm.mirrored:
    TextGraphic(lm.graphic).
      setText "-".repeat(lm.source.maxHealth - lm.source.health) &
              "/".repeat(lm.source.health)
    lm.centrify(HAlign.right, VAlign.bottom)
  else:
    TextGraphic(lm.graphic).
      setText "\\".repeat(lm.source.health) &
              "-".repeat(lm.source.maxHealth - lm.source.health)
    lm.centrify(HAlign.left, VAlign.bottom)


proc init*(lm: LifeMeter, source: Character, mirrored = false) =
  lm.initEntity()
  lm.source = source
  lm.mirrored = mirrored
  lm.graphic = newTextGraphic defaultFont
  TextGraphic(lm.graphic).color = Color(r: 191, g: 0, b: 0, a: 255)
  lm.updateLifeMeter 0.0


proc newLifeMeter*(source: Character, mirrored = false): LifeMeter =
  new result
  init result, source, mirrored


method update*(lm: LifeMeter, elapsed: float) =
  lm.updateEntity elapsed
  lm.updateLifeMeter elapsed

