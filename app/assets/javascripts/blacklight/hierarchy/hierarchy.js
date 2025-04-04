Blacklight.onLoad(() => Blacklight.do_hierarchical_facet_expand_contract_behavior())

(() => {
  Blacklight.do_hierarchical_facet_expand_contract_behavior = () => {
    const elements = document.querySelectorAll(Blacklight.do_hierarchical_facet_expand_contract_behavior.selector)
    elements.forEach(elem => Blacklight.hierarchical_facet_expand_contract(elem))
  }
  Blacklight.do_hierarchical_facet_expand_contract_behavior.selector = '[data-controller="b-h-collapsible"]'
  Blacklight.do_hierarchical_facet_expand_contract_behavior.handle = '[data-action="click->b-h-collapsible#toggle"]'
  Blacklight.do_hierarchical_facet_expand_contract_behavior.list = '[data-b-h-collapsible-target="list"]'

  Blacklight.hierarchical_facet_expand_contract = (element) => {
    element.classList.add('twiddle')

    const lists = element.querySelectorAll(Blacklight.do_hierarchical_facet_expand_contract_behavior.list)

    lists.forEach((list) => {
      if (list.querySelector('span.selected')) {
        element.classList.add('twiddle-open')
        const collapseElement = element.querySelector('.collapse')
        if (collapseElement) {
          collapseElement.classList.add('show')
        }
      }
    })

    // attach the toggle behavior to the li tag
    const handle = element.querySelector(Blacklight.do_hierarchical_facet_expand_contract_behavior.handle)
    handle?.addEventListener('click', () => element.classList.toggle('twiddle-open'))
  }
})()
