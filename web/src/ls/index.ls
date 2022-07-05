[w,h] = [1170,658]
[patw,path] = [193,278]
[of1x,of1y] = [298,273]
[dpw,dph] = [59,20]
angular.module \ERGame, <[]>
  ..controller \ERGame, <[$scope $interval $timeout]> ++ ($scope, $interval, $timeout) ->
    $scope.list = [[(i % 4), parseInt(i / 4)] for i from 0 til 12]
    $scope.pixel = do
      scene: w: 1170, h: 658

      sprite: do
        size: [
          * w:   0, h:   0 #  0 reserved
          * w: 101, h: 142 #  1 候診病人
          * w: 108, h: 229 #  2 留觀病人(朝左)
          * w: 108, h: 229 #  3 留觀病人(朝右)
          * w: 291, h: 245 #  4 病床病人
          * w: 316, h: 269 #  5 料理台
          * w: 105, h: 196 #  6 飲水機
          * w: 146, h: 239 #  7 廁所
          * w:  98, h:  60 #  8 香蕉
          * w: 306, h: 298 #  9 醫生台
          * w: 191, h: 240 # 10 隔簾
          * w: 104, h: 136 # 11 左窗
          * w: 238, h: 184 # 12 右窗
          #* w: 358, h: 451 # 10 隔簾
        ]
        points:
          [{x: 591, y: -19, type: 6}] ++
          [{x: 317, y: -3, type: 5}] ++
          [{x: 687, y: -36, type: 7}] ++
          [{x: 503, y: 65, type: 8}] ++ 
          [{x: 507, y: 54, type: 9, variant: 1}] ++
          [{x: 249, y: 184, type: 11}] ++
          [{
            x: 293 + c * 59 + r * -127, y: 222 + c * 20 + r * 47, 
            type: 1, variant: 0, active: 1
          } for r from 0 til 3 for c from 0 til 4] ++ 
          [
            * x: 857, y: 100, type: 4, variant: 0, active: 1
          ] ++
          [{x: 870, y: 272, type: 12}] ++
          [{x: 749 + i * 66, y: 227 + i * 24, type: 2, variant: 0, active: 1} for i from 0 til 5] ++
          [
            * x: 623, y: 279, type: 3, variant: 0, active: 1
            * x: 520, y: 341, type: 10
            * x: 730, y: 387, type: 4, variant: 0, active: 1
            * x: 335, y: 387, type: 4, variant: 0, active: 1
            * x: 493, y: 418, type: 3, variant: 0, active: 1
            * x: 678, y: 418, type: 2, variant: 0, active: 1
          ]

    $scope.percent = do
      sprite: do
        size: [{
          w: 100 * p.w / $scope.pixel.scene.w
          h: 100 * p.h / $scope.pixel.scene.h
        } for p in $scope.pixel.sprite.size]
        points: [{
          x: 100 * p.x / $scope.pixel.scene.w,
          y: 100 * p.y / $scope.pixel.scene.h,
          type: p.type, variant: p.variant, active: p.active
        } for p in $scope.pixel.sprite.points ]

    $scope.rebuild = ->
      for it in $scope.percent.sprite.points =>
        it.cls = (
          (if it.active => <[active]> else []) ++ 
          ["it-#{it.type}-#{it.variant or 0}-#{it.active or 0}"]
        )

    $scope.game = do
      # 0 - landing
      # 1 - pause
      # 2 - playing
      # 3 - tutorial
      # 4 - game over
      # 5 - countdown
      state: 0
      set-state: -> 
        @state = it
      start: ->
        @set-state 5
        @countdown.start!
      reset: ->
        $scope.patient.reset!
        $scope.doctor.reset!
        $scope.supply.reset!
        $scope.mouse.reset!
        $scope.rebuild!
        $scope <<< {madmax: 0}
        $scope.dialog.toggle null, false
        @state = 0
      countdown: do
        handler: null
        value: 0
        count: ->
          @value = @value - 1
          if @value => $timeout (~> @count!), 650
          else => $scope.game.set-state 2
        start: ->
          @value = 5
          @count!
    $scope.doctor = do
      sprite: $scope.percent.sprite.points.filter(->it.type==9).0
      handler: null
      energy: 1
      faint: false
      chance: 5
      hurting: 0
      fail: -> 
        @
          ..set-mood 7
          ..chance -= 1
          ..chance >?= 0
          ..hurting = 1 # 震動倒數
        if @chance <= 0 => $scope.game.set-state 4
      reset: ->
        @ <<< {energy: 1, faint: false, chance: 5, hurting: 0}
        if @handler => $timeout.cancel @handler
        @set-mood 1
      score: do
        digit: [0,0,0,0]
        value: 0
      reset-later: ->
        if @handler => $timeout.cancel @handler
        @handler = $timeout((~> 
          @set-mood 1
          @handler = null
          $scope.rebuild!
        ), 1000)

      set-mood: ->
        @sprite.variant = it
        if it > 1 => @reset-later!
        #TODO: normalize image width / height
    $scope.$watch 'doctor.score.value', ->
      score = $scope.doctor.score
      for i from 0 til 4 =>
        score.digit[ 3 - i ] = parseInt(score.value / (10 ** i)) % (10 ** (i+1))

    $scope.supply = do
      sprite: $scope.percent.sprite.points.filter(->it.type in [5 6 7 8])
      reset: ->
        for item in @sprite => item <<< {active: 0, countdown: -1}
      active: (defidx, isOn=true) ->
        if !defidx? => idx = parseInt(Math.random!*@sprite.length)
        else idx = defidx
        if !isOn =>
          @sprite[idx].active = 0
          delete @sprite[idx].countdown
        else =>
          @sprite[idx].active = 1
          @sprite[idx].countdown = 1

    $scope.patient = do
      lvprob: [
        [0.6, 0.9],
        [0.4, 0.8],
        [0.3, 0.3],
      ]
      reset: ->
        remains = $scope.percent.sprite.points.filter( ->it.type >=1 and it.type <= 4 )
        for item in remains => item <<< {variant: 0, mad: 0, life: 1}
      add: (area, defvar, defpos) ->
        remains = $scope.percent.sprite.points.filter(-> it.type == area and it.variant == 0)
        if remains.length == 0 => return
        variant = parseInt(Math.random! * 3 + 1)
        if area == 1 =>
          dice = Math.random!
          if dice < @lvprob.0.0 => variant = 1
          else if dice < @lvprob.0.1 => variant = 2
          else variant = 3
        else => variant = parseInt(Math.random! * 2 + 1)
        if area > 1 => variant <?= 2
        if defvar? => variant = defvar
        idx = if defpos? => defpos else parseInt(Math.random!*remains.length)
        des = remains[idx]
        des.variant = variant
        if des.type == 1 => des.life = 1
        if des.type in [2 3 4] => des.mad = 0
        $scope.rebuild!

    $scope.mouse = do
      x: 0, y: 0, target: null
      reset: -> @target = null
      lock: -> @is-locked = true
      unlock: -> @is-locked = false
      down: (e, target)->
        if isHalt! => return
        if @is-locked or $scope.madmax or $scope.doctor.faint => return
        offset = $(\#wrapper).offset!
        [x,y] = [@x, @y] = [e.clientX - offset.left, e.clientY - offset.top]
        target = $scope.hitmask.resolve(x, y)
        if !target => return
        if target.type == 1 =>
          if target.variant == 0 => return
          pat = $scope.percent.sprite.points.filter(->it.type == 1)
          max = 0
          for item in pat => if item.variant > max => max = item.variant
          if max == 3 and target.variant < max => 
            @target = null
            return

        @target = target
        if !target or target.type != 1 => return
        $(\#wheel).css do
          display: "block"
          top: "#{y}px"
          left: "#{x}px"
        $scope.rebuild!
      up: (e) -> 
        if isHalt! => return
        if @is-locked or $scope.madmax or $scope.doctor.faint => return
        <~ setTimeout _, 0
        $(\#wheel).css({display: "none"})
        offset = $(\#wrapper).offset!
        [dx, dy] = [e.clientX - @x - offset.left, e.clientY - @y - offset.top]

        angle = Math.acos( dx / Math.sqrt( dx ** 2 + dy ** 2 ) ) * 360 / ( Math.PI * 2 )
        if dy > 0 => angle = 360 - angle
        if angle >= 320 or angle <= 10 => type = 3
        if angle > 10 and angle <=61 => type = 2
        if angle > 61 and angle < 112 => type = 1
        if @target =>
          # 待診病人
          if @target.type == 1 =>
            # 正確回答
            if @target.variant == type => 
              if @target.variant == 1 => # 輕症病患
                # 一定機率濫用資源
                mood = if Math.random! < 0.5 => 2 else 4 + parseInt(Math.random! * 3)
                if @forceMood? => mood = @forceMood
                $scope.doctor.set-mood mood
                # 非濫用資源者才計分
                if mood == 2 => $scope.doctor.score.value += 1
              else # 中、重症病患
                # 一定機率進留觀
                if (!(@forceStay?) and Math.random! > 0.5) =>
                  $scope.doctor.set-mood 3
                  $scope.patient.add parseInt(3 * Math.random! + 2)
                else if @forceStay =>
                  $scope.doctor.set-mood 3
                  $scope.patient.add 4, 2, 0
                else $scope.doctor.set-mood 2
                $scope.doctor.score.value += 1
            else => $scope.doctor.fail! # 答錯，難過，扣血

            @target.variant = 0
            $scope.rebuild!
          else if @target.type >= 2 and @target.type <= 4 =>
            if @target.mad > 0.8 => @target.mad = 0.8
            @target.mad <?= 0.8
            @target.mad -= 0.2
            @target.mad >?= 0
          else if @target.type >= 5 and @target.type <= 8 and @target.active => # 恢復體力
            $scope.doctor.energy += 0.1
            $scope.doctor.energy <?= 1
            $scope.doctor.set-mood 2
            $scope.rebuild!
            @target.active = 0
            @target.countdown = 1
        @target = null

    $scope.madmax = 0
    $scope.demad = (e) ->
      madmax = $scope.percent.sprite.points.filter(-> (it.mad?) and (it.mad >= 1)) 
      if !madmax.length => $scope.madmax = 0
      if madmax.length => 
        madmax.0.mad <?= 0.8
        madmax.0.mad -= 0.1
        madmax.0.mad >?= 0
      else if $scope.doctor.faint =>
        $scope.doctor
          ..energy += 0.1
          ..energy <?= 1
        if $scope.doctor.energy == 1 => $scope.doctor.faint = false
      e.preventDefault!
      return false

    $scope.rebuild!
    isHalt = ->
      if ($scope.game.state != 2 and $scope.game.state != 3) or $scope.dialog.show == true => return true
      return false
    $interval ( ->
      if isHalt! => return
      if $scope.dialog.tut => return
      if Math.random! < 0.1 => $scope.patient.add 1
      if Math.random! < 0.1 => $scope.supply.active!
    ), 100

    $scope.madspeed = 0.002
    $interval (->
      if isHalt! => return
      if $scope.doctor.hurting => 
        $scope.doctor.hurting -= 0.2
        $scope.doctor.hurting >?= 0
      inqueue = $scope.percent.sprite.points.filter(->it.type == 1 and it.variant > 0)
      for it in inqueue
        it.life -= ( 0.004 * it.variant )
        if it.life <= 0 => 
          it.life = 0
          $scope.doctor.fail!
          it.variant = 0

      inqueue = $scope.percent.sprite.points.filter(->(it.type in [2 3 4]) and it.variant > 0)
      madmax = 0
      for it in inqueue
        if !(it.mad?) => it.mad = 0
        it.mad += $scope.madspeed
        if it.mad >= 0.8 => 
          it.mad = 1
          madmax = 1
      if madmax and !$scope.madmax => $scope.madmax = parseInt( Math.random!*2 + 1 )

      if !$scope.doctor.faint =>
        inqueue = $scope.percent.sprite.points.filter(->(it.type in [5 6 7 8]) and it.active)
        for it in inqueue
          if !(it.countdown?) or it.countdown <= 0 => it.countdown = 1
          it.countdown -= 0.025
          if it.countdown <= 0 =>
            it.countdown = 1
            it.active = 0
            $scope.doctor.energy -= 0.2
            $scope.doctor.energy >?= 0
            if $scope.doctor.energy == 0 => $scope.doctor.faint = true

    ), 100
    $scope.$watch 'madmax' -> if it => $(\#wheel).css({display: "none"})

    $scope.hitmask = do
      ready: false
      get: (x, y) ->
        if !@ready => return [0,0,0,0]
        @ctx.getImageData(x,y,1,1).data
      resolve: (x,y) ->
        color = @get x,y
        type = color.0
        if type == 0 => return null
        else if type ==1 => order = color.1 * 4 + color.2
        else => order = color.2
        $scope.percent.sprite.points.filter(->it.type == type)[order]
      init: ->
        @canvas = document.createElement("canvas")
          ..height = 576
          ..width = 1024
        @ctx = @canvas.getContext \2d
        @img = new Image!
        @img.src = \mask.png
        @img.onload = ~> 
          @ctx.drawImage @img, 0, 0, 1024, 576
          @ready = true

    $scope.hitmask.init!
    $scope.dialog = do
      tut: true
      show: false
      idx: 0
      next: -> $timeout (~> @main true), 200
      type: ""
      h: {i: [], t: []}
      skip: ->
        for item in @h.i => $interval.cancel item
        for item in @h.t => $timeout.cancel item
        @idx = @step.length - 2
        @toggle 0, true
      interval: (func, delay) ->
        ret = $interval func, delay
        @h.i.push ret
        ret
      timeout: (func, delay) ->
        ret = $timeout func, delay
        @h.t.push ret
        ret
      clean: ->
        delete $scope.mouse.forceStay
        delete $scope.mouse.forceMood
        $scope.dialog.tut = false
        $scope.mouse.unlock!
        $(\#score).remove-class \hint
        $scope.doctor
          ..chance = 5
          ..hurting = 0
          ..faint = false
          ..energy = 1
          ..set-mood 2
        $scope.game.set-state 2
      step: [
        * {}
        * do
            ready: false
            check: -> 
              if !@ready and $scope.game.state == 2 => 
                $scope.game.state = 3
                @ready = true
              @ready
            fire: ->
              $scope.mouse.forceStay = false
              $scope.mouse.forceMood = 1
              $scope.mouse.lock!
              $scope.dialog.timeout (-> $scope.patient.add 1, 1, 0), 1000
              $scope.dialog.timeout (-> $scope.patient.add 1, 2, 0), 2000
              $scope.dialog.timeout (-> $scope.patient.add 1, 3, 0), 3000
        * do
            ready: false
            check: -> 
              if @ready => return true
              if $scope.percent.sprite.points.filter(->it.type==1 and it.variant==3).length > 0 =>
                $scope.dialog.timeout (~> @ready = true), 1000
              return false
        * { check: -> true }
        * do
            check: -> true
            fire: -> 
              $(\#finger-slide).css do
                display: \block
                top: \33%
                left: \22%
              set-timeout ->
                $(\#finger-slide).css display: \none
                $scope.mouse.unlock!
              , 3000
        * do
            check: ->
              ret = ($scope.percent.sprite.points.filter(->it.type==1 and it.variant != 0).length == 0)
              if ret => 
                $scope.dialog.type = \mini
                @handler = $scope.dialog.timeout (~> 
                  $scope.doctor.fail!
                  @handler = null
                ), 500
              ret
            fire: -> 
              $scope.doctor <<< {chance: 5, hurting: 0}
              if @handler => $timeout.cancel @handler
        * check: -> 
            $(\#score).add-class \hint
            true
          fire: ->
            $(\#score).remove-class \hint
        * do
            mood: 0
            check: -> 
              if !(@handler?) => 
                @handler = $scope.dialog.interval (~>
                  $scope.doctor.set-mood @mood + 4
                  $scope.rebuild!
                  @mood = ( @mood + 1 ) % 3
                ), 500
              true
            fire: -> 
              $scope.doctor.set-mood 1
              $scope.rebuild!
              $interval.cancel @handler
              $scope.mouse.forceStay = true
              $scope.patient.add 1, 2, 0
        * do
            mood: 3
            ready: false
            handler: null
            mood-handler: null
            check: -> 
              has-pat2 = ($scope.percent.sprite.points.filter(->it.type==4 and it.variant > 0).length > 0)
              has-pat1 = ($scope.percent.sprite.points.filter(->it.type==1 and it.variant==2).length > 0)
              if has-pat2 and !@handler? => 
                @handler = $scope.dialog.timeout (~> @ready = true), 1000
              if !has-pat2 and !has-pat1 =>
                $scope.patient.add 1, 2, parseInt(1 + Math.random! * 4)
              if @ready and !@mood-handler =>
                @mood-handler = $scope.dialog.interval (~>
                  $scope.doctor.set-mood @mood
                  $scope.rebuild!
                  @mood = 4 - @mood
                ), 500
              return @ready
            fire: ->
              $interval.cancel @mood-handler
              $(\#finger-tap).css do
                display: \block
                top: \22%
                left: \68%
              $scope.madspeed = 0.02
              $scope.dialog.timeout (->
                $(\#finger-tap).css display: \none
              ), 1300
        * do
            ready: false
            handler: null
            check: -> 
              if $scope.madspeed == 0.02 and $(\#finger-tap).css(\display) == \none and !@handler =>
                @handler = $scope.dialog.timeout (~> @ready = true), 2000
              @ready
            fire: ->
              $scope.mouse.lock!
        * do
            launched: 0
            supply: 0
            ready: false
            check: -> 
              if $scope.madmax >= 1 and @launched==0 =>
                @launched = 1
                $(\#finger-tap).css do
                  display: \block
                  top: \30%
                  left: \30%
                $scope.madspeed = 0.002
                $scope.dialog.timeout (-> $(\#finger-tap).css display: \none), 1000
              if $scope.madspeed == 0.002 and $scope.madmax < 1 and @launched == 1 => 
                @launched = 2
                $scope.percent.sprite.points.filter(->it.type == 4).0.mad = 0
                $scope.dialog.timeout (~>
                  @handler = $scope.dialog.interval (~>
                    $scope.supply.active @supply, false
                    @supply = ( @supply + 1 ) % 4
                    $scope.supply.active @supply
                  ), 500
                  $(\#arrow).css do
                    display: \block
                    top: \25%
                    left: \35%
                  @ready = true
                ), 1000
              @ready
            fire: -> 
              $interval.cancel @handler
              $scope.supply.active 0, false
              $scope.supply.active 1, true
              $scope.supply.active 2, false
              $scope.supply.active 3, false
              $(\#arrow).css display: \none
              $(\#finger-tap).css do
                display: \block
                top: \7%
                left: \20%
              $scope.dialog.timeout (-> $(\#finger-tap).css display: \none), 1000
        * do
            ready: false
            handler: false
            check: -> 
              if !@handler => 
                @handler = $scope.dialog.timeout (~> 
                  @ready = true
                  $scope.supply.active 1, false
                  $scope.doctor.set-mood 7
                  $scope.rebuild!
                  $scope.doctor.energy -= 0.1
                  $(\#arrow).css do
                    display: \block
                    top: \10%
                    left: \31%
                ), 3000
              @ready
            fire: ->
              $(\#arrow).css display: \none
              $scope.doctor.energy = 0
              $scope.doctor.faint = true
              $(\#finger-tap).css do
                display: \block
                top: \20%
                left: \30%
              $scope.dialog.timeout (->
                $(\#finger-tap).css display: \none
              ), 1000
        * do
            ready: false
            check: -> 
              console.log \hit
              if !@handler? and $scope.doctor.energy == 1 and $scope.doctor.faint == false =>
                @handler = $scope.dialog.timeout (~> 
                  @ready = true
                  $scope.dialog.type = ""
                ), 1000
              @ready
            fire: -> $scope.dialog.clean!
        * check: -> false
      ]
      main: (force = false) ->
        if force and @step[@idx] and @step[@idx].fire and !@step[@idx].fired => 
          @step[@idx].fire!
          @step[@idx].fired = true
        if @show and !force => return
        if @step[@idx + 1] and @step[@idx + 1].check! => @toggle @idx + 1, true
        else @toggle 0, false
      toggle: (idx, isOn) -> 
        if idx => @idx = idx
        <~ setTimeout _, 0
        if !(isOn?) => @show = !@show
        else @show = isOn
        if @show => $(\#dialog).fadeIn! else $(\#dialog).fadeOut!
    $interval (->$scope.dialog.main!), 100
