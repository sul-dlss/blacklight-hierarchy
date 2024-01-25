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
    li.addClass('twiddle');

    $(Blacklight.do_hierarchical_facet_expand_contract_behavior.list, this).each(function() {
      if($('span.selected', this).length != 0){
        li.addClass('twiddle-open');
        li.children('.collapse').addClass('show');
      }
    });

    // attach the toggle behavior to the li tag
    li.children(Blacklight.do_hierarchical_facet_expand_contract_behavior.handle).click(function(e){
      li.toggleClass('twiddle-open');
    });
  };
})(jQuery);
