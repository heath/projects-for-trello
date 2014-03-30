tags = [
    bgColor : "blue"
    color   : "yellow"
    name    : "foo"
  ,
    bgColor : "yellow"
    color   : "green"
    name    : "bar"
]


showLabels = ->
  $(".list").each -> readCard $(this).find ".list-card"


readCard = ($c) ->
  if $c.target
    return unless /list-card/.test($c.target.className)
    $c = $($c.target).filter ".list-card:not(.placeholder)"
  $c.each ->
    if not @listCard then new ListCard(this) else @listCard.refresh()


randomHexColor = ->
  "#" + Math.random().toString(16).slice 2, 8


tagExists = (label) ->
  tags.some (tag) -> tag.name is label


genCssSelector = (label) ->
  if tagExists label
    for i,tag of tags
      if tag.name is label
        $(".#{label}").css
          backgroundColor : tags[i].bgColor
          color           : tags[i].color
  else
    tag =
      bgColor : randomHexColor()
      color   : randomHexColor()
      name    : label
    tags.push tag

    $(".#{label}").css
      backgroundColor : tag.bgColor
      color           : tag.color
      

ListCard = (el) ->
  return if el.listCard

  busy    = false
  label   = -1
  parsed  = undefined
  ptitle  = ""
  regexp  = /\{([^{}]+)\}/
  tagName = undefined

  @refresh = ->
    return if busy
    busy = true

    recursiveReplace = ->
      $("<div class='badge project #{label[1]}' />").text(label[1]).prependTo $(el).find(".badges")
      genCssSelector label[1]
        
      $title[0].childNodes[1].textContent = el._title = $.trim(el._title[0].text.replace(label[0], ""))
      parsed = el._title.match(regexp)
      label = (if parsed then parsed else -1)

      unless label is -1
        el._title = $title
        recursiveReplace()

    $(el).find(".project").remove()
    $title = $(el).find("a.list-card-title")

    return unless $title[0]
    title = $title[0].childNodes[1].textContent
    if title then el._title = $title

    unless title is ptitle
      ptitle = title
      parsed = title.match(regexp)
      label  = if parsed then parsed else -1

    recursiveReplace()
    busy = false

  @refresh()


document.addEventListener "DOMNodeInserted", ->
  showLabels() if event.target.id is "board" or $(event.target).hasClass("list")
  if $(".badge").length > 0

    $(".badge").hover (handlerIn = ->

      allCards = $(".list-card-details")

      allCards.css
        background : "rgba(0,0,0,0.5)"
        opacity    : 0.2

      visibleCards = allCards.filter (i, card) ->
        $(card).find(".badge." + event.target.innerText).length > 0

      visibleCards.css
        background : "#fff"
        opacity    : 1.0

    ), handlerOut = ->
      $(".list-card-details").css
        background : "#fff"
        opacity    : 1.0


$(".js-toggle-label-filter, .js-select-member, .js-due-filter, .js-clear-all").on "mouseup", showLabels
$(".js-input").on "keyup", showLabels


showLabels()
