require "./init.coffee"
{
    HEIGHT, WIDTH, A_KEY, D_KEY, W_KEY, S_KEY, J_KEY
} = require "./constants.coffee"

game = null
MAN_SPRITE = "assets/images/man.png"
STUPID_SPRITE = "assets/images/stupid.png"
man = null
ledges = null
stars = null
scoreText = null
score = 0
velocity = 150

initGame = ->
    game = window.game = new Phaser.Game WIDTH, HEIGHT, Phaser.AUTO, "", {
        preload: preload
        create: create
        update: update
    }

preload = ->
    game.load.onFileComplete.add ->
        console.log 'Loading..', game.load.progress
    game.load.image "star", "assets/images/star.png"
    game.load.spritesheet "man", MAN_SPRITE, 32, 48
    game.load.image "sky", "assets/images/sky.png"
    game.load.image "ground", "assets/images/ground.png"
    game.load.image "stupid", STUPID_SPRITE
    game.load.image "diamond", "assets/images/diamond.png"

create = ->
    addBackground()
    makePhysicsWorld()
    makeLedge()
    makeMan()
    makeStars()
    makeScore()
    makeButtons()
    listenTouch()


makePhysicsWorld = ->    
    game.physics.startSystem Phaser.Physics.ARCADE

makeMan = ->
    man = game.add.sprite WIDTH / 2, HEIGHT / 2, 'man'
    man.anchor.setTo 0.5, 0.5
    game.physics.arcade.enable man
    man.body.collideWorldBounds = yes
    man.body.gravity.y = 1000
    # man.angle = 30
    # man.body.velocity.x = Math.random() * 1000
    # man.body.velocity.y = Math.random() * 1000
    # man.body.bounce.x = 0.5
    # man.body.bounce.y = 0.5
    man.frame = 4
    man.animations.add "left", [0..3], 10, yes
    man.animations.add "right", [5..8], 10, yes

makeStars = ->
    stars = game.add.group()
    stars.enableBody = yes
    for i in [0..(WIDTH - 10) / 40]
        star = stars.create 5 + i * 40, 20, "star"
        star.body.gravity.y = 100
        star.body.bounce.y = 0.7 + Math.random() * 0.2

makeScore = ->
    scoreText = game.add.text 16, 16, "Score: 0", {font: "bold 20px Arial", fill: "red"}

makeLedge = ->
    ledges = game.add.group()
    ledges.enableBody = yes

    groundHeight = 50
    ground = ledges.create 0, HEIGHT - groundHeight, 'ground'
    ground.scale.setTo WIDTH / 400, HEIGHT / 32
    ground.body.immovable = yes

    leds = [
        {x: 0, y: HEIGHT - 150, width: 100, height: 20}
        {x: WIDTH - 130, y: HEIGHT - 240, width: 130, height: 20}
        {x: 0, y: HEIGHT - 340, width: 100, height: 20}
    ]

    for led in leds
        ledge = ledges.create led.x, led.y, 'ground'
        ledge.scale.setTo led.width / 400, led.height / 32
        ledge.body.immovable = yes

addBackground = ->
    game.add.sprite 0, 0, 'sky'

update = ->    
    game.physics.arcade.collide man, ledges
    game.physics.arcade.collide stars, ledges
    game.physics.arcade.overlap man, stars, (man, star)->
        score += 10
        scoreText.text = "Score: #{score}"
        star.kill()
    listenAndMakeManMove()

listenAndMakeManMove = ->
    keyboard = game.input.keyboard
    man.body.velocity.x = 0
    if (keyboard.isDown A_KEY) or isTouchLeft()
        runLeft()
    else if (keyboard.isDown D_KEY) or isTouchRight()
        runRight()
    else
        man.animations.stop()
        if man.isLeft then man.frame = 0 else man.frame = 5

    if man.body.touching.down and (isJump or (keyboard.isDown J_KEY))
        jump()

isTouchRight = ->
    # console.log direct
    direct is 'right'

isTouchLeft = ->
    # console.log direct
    direct is 'left'

direct = null
isJump = no
listenTouch = ->
    # game.input.onUp.add (event)->
    #     direct = null
    #     isJump = no

runLeft = ->
    man.body.velocity.x = -velocity
    man.animations.play "left"
    man.isLeft = yes

runRight = ->
    man.body.velocity.x = velocity
    man.animations.play "right"
    man.isLeft = no

jump = ->
    man.body.velocity.y = -500

makeButtons = ->
    left = game.add.button 16, HEIGHT - 50, "diamond"
    right = game.add.button 90, HEIGHT - 50, "diamond"
    jumpBtn = game.add.button WIDTH - 70, HEIGHT - 50, "diamond"
    left.scale.setTo 2, 2
    right.scale.setTo 2, 2
    jumpBtn.scale.setTo 2, 2
    left.onInputDown.add (event)-> 
        direct = 'left'
    left.onInputUp.add (event)-> 
        direct = null
    right.onInputDown.add -> 
        direct = 'right'
    right.onInputUp.add (event)-> 
        direct = null
    jumpBtn.onInputDown.add -> 
        isJump = yes
    jumpBtn.onInputUp.add (event)-> 
        isJump = no
    right.onInputUp.add (event)-> 
    window.left = left


initGame()