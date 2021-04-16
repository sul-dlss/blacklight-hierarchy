Blacklight.onLoad(function(){
  Blacklight.do_hierarchical_facet_expand_contract_behavior();
});

(function($) {
  Blacklight.do_hierarchical_facet_expand_contract_behavior = function() {
    $( Blacklight.do_hierarchical_facet_expand_contract_behavior.selector ).each (
        Blacklight.hierarchical_facet_expand_contract
     );
  }
  Blacklight.do_hierarchical_facet_expand_contract_behavior.selector = '[data-controller="b-h-collapsible"]';
  Blacklight.do_hierarchical_facet_expand_contract_behavior.handle = '[data-action="click->b-h-collapsible#toggle"]';
  Blacklight.do_hierarchical_facet_expand_contract_behavior.list = '[data-b-h-collapsible-target="list"]';

  Blacklight.hierarchical_facet_expand_contract = function() {
    var li = $(this);

    $(Blacklight.do_hierarchical_facet_expand_contract_behavior.list, this).each(function() {
      li.addClass('twiddle');
      if($('span.selected', this).length == 0){
        $(this).hide();
      } else {
        li.addClass('twiddle-open');
        li.children(Blacklight.do_hierarchical_facet_expand_contract_behavior.handle).attr('aria-expanded', 'true');
      }
    });

    // attach the toggle behavior to the li tag
    li.children(Blacklight.do_hierarchical_facet_expand_contract_behavior.handle).click(function(e){
      // toggle the content
      $(this).attr('aria-expanded', $(this).attr('aria-expanded') === 'true' ? 'false' : 'true');
      $(this).parent('li').toggleClass('twiddle-open');
      $(this).parent('li').children(Blacklight.do_hierarchical_facet_expand_contract_behavior.list).slideToggle();
    });
  };
})(jQuery);
