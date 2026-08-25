document.addEventListener("DOMContentLoaded", function () {
  var input = document.getElementById("person-search")
  var results = document.getElementById("person-search-results")
  if (!input || !results) return

  var timer = null

  input.addEventListener("input", function () {
    clearTimeout(timer)
    var query = input.value.trim()

    if (query.length < 2) {
      results.innerHTML = ""
      return
    }

    timer = setTimeout(function () {
      fetch("/people/search.json?q=" + encodeURIComponent(query))
        .then(function (response) { return response.json() })
        .then(renderResults)
    }, 200)
  })

  document.addEventListener("click", function (event) {
    if (event.target !== input && !results.contains(event.target)) {
      results.innerHTML = ""
    }
  })

  function renderResults(people) {
    results.innerHTML = ""

    people.forEach(function (person) {
      var li = document.createElement("li")
      var a = document.createElement("a")
      a.href = person.url
      a.textContent = person.status ? person.name + " — " + person.status : person.name
      li.appendChild(a)
      results.appendChild(li)
    })
  }
})
