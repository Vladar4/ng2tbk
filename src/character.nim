import
  nimgame2 / [
    assets,
    audio,
    entity,
    input,
    texturegraphic,
    types,
  ],
  data


type
  ControlKind* = enum
    ckNone
    ckPlayer1
    ckPlayer2
    ckAI

  Character* = ref object of Entity
    control*: ControlKind


proc init*(character: Character, graphic: TextureGraphic) =
  character.initEntity()
  character.tags.add "character"
  character.graphic = graphic
  character.initSprite((180, 120))
  discard character.addAnimation(
    "forward", toSeq(0..7), Framerate)
  discard character.addAnimation(
    "backward", toSeq(7..0), Framerate)

  # collider
  let c = newGroupCollider character
  character.collider = c
  c.list.add newBoxCollider(
    character, (CharacterOffset, 60), (CharacterOffset, 120))


proc colliderOffset(character: Entity, x: float) =
  let c = GroupCollider(character.collider)
  for i in c.list:
    i.pos.x = x


proc newCharacter*(graphic: TextureGraphic): Character =
  new result
  result.init graphic


proc characterAnimEnd(character: Entity, index: int) =
  if index == character.animationIndex("forward"):
    character.pos.x += CharacterOffset
  elif index == character.animationIndex("backward"):
    character.play("forward", 0)


method update*(character: Character, elapsed: float) =
  character.updateEntity elapsed
  if not character.sprite.playing:
    # control
    case character.control:
    of ckNone: discard
    of ckPlayer1:
      if player1key.a.down:
        character.play("forward", 1, callback = characterAnimEnd)
      if player1key.b.down:
        character.pos.x -= CharacterOffset
        character.play("backward", 1, callback = characterAnimEnd)
      discard
    of ckPlayer2:
      #TODO
      discard
    of ckAI:
      #TODO
      discard



method onCollide*(character: Character, target: Entity) =
  #TODO
  discard

