tags = [ "foo", "bar", "baz" ]

showLabels = ->
  $(".list").each ->
    new List(this)  unless @list

randomHexColor = ->
  "#" + Math.floor(Math.random() * 16777215).toString(16)

genNewTag = (tag) ->
  $("." + tag).css "backround-color", randomHexColor()

readCard = ($c) ->
  if $c.target
    return unless /list-card/.test($c.target.className)
    $c = $($c.target).filter(".list-card:not(.placeholder)")
  $c.each ->
    unless @listCard
      new ListCard(this)
    else
      @listCard.refresh()

List = (el) ->
  return if el.list
  el.list = this
  $list = $(el)
  busy = false
  $list.on "DOMNodeInserted", readCard
  readCard $list.find(".list-card")

ListCard = (el) ->
  return if el.listCard
  el.listCard = this
  regexp = /\{([^{}]+)\}/
  label = -1
  parsed = undefined
  that = this
  busy = false
  ptitle = ""
  $card = $(el)
  tag = undefined
  @refresh = ->
    recursiveReplace = ->
      unless label is -1
        tags.forEach (text) ->
          if text is label[1]
            tag = text
          # else
          #   tag = label[1]
          #   genNewTag(tag)

        $("<div class=\"badge " + tag + "\" />").text(label[1]).prependTo $card.find(".badges")
        $title[0].childNodes[1].textContent = el._title = $.trim(el._title[0].text.replace(label[0], ""))
        parsed = el._title.match(regexp)
        label = (if parsed then parsed else -1)

        unless label is -1
          el._title = $title
          recursiveReplace()

    return if busy
    busy = true
    $card.find(".project").remove()
    $title = $card.find("a.list-card-title")
    return unless $title[0]
    title = $title[0].childNodes[1].textContent
    el._title = $title  if title

    unless title is ptitle
      ptitle = title
      parsed = title.match(regexp)
      label = (if parsed then parsed else -1)

    recursiveReplace()
    busy = false

  @refresh()

$(".js-toggle-label-filter, .js-select-member, .js-due-filter, .js-clear-all").on "mouseup", showLabels
$(".js-input").on "keyup", showLabels
showLabels()

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
