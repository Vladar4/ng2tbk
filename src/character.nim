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
    left*: bool # false - right, true - left


proc init*(character: Character, graphic: TextureGraphic) =
  character.initEntity()
  character.tags.add "character"
  character.graphic = graphic
  character.initSprite((180, 120))
  discard character.addAnimation(
    "right", toSeq(0..7), Framerate)
  discard character.addAnimation(
    "left", toSeq(0..7), Framerate, flip = Flip.horizontal)

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
  if index == character.animationIndex("right"):
    character.pos.x += CharacterOffset
  elif index == character.animationIndex("left"):
    character.pos.x -= CharacterOffset


method update*(character: Character, elapsed: float) =
  character.updateEntity elapsed
  if not character.sprite.playing:
    # control
    case character.control:
    of ckNone: discard
    of ckPlayer1:
      if player1key.a.down:
        if character.left: character.pos.x += CharacterOffset
        character.colliderOffset CharacterOffset
        character.play("right", 1, callback = characterAnimEnd)
        character.left = false
      if player1key.b.down:
        if not character.left: character.pos.x -= CharacterOffset
        character.colliderOffset CharacterOffset2
        character.play("left", 1, callback = characterAnimEnd)
        character.left = true
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

