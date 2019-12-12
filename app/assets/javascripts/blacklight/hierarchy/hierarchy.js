Blacklight.onLoad(function(){
  Blacklight.do_hierarchical_facet_expand_contract_behavior();
});

(function($) {
  Blacklight.do_hierarchical_facet_expand_contract_behavior = function() {
    $( Blacklight.do_hierarchical_facet_expand_contract_behavior.selector ).each (
        Blacklight.hierarchical_facet_expand_contract
     );
  }
  Blacklight.do_hierarchical_facet_expand_contract_behavior.selector = 'li.h-node';

  Blacklight.hierarchical_facet_expand_contract = function() {
    var li = $(this);

    $('ul', this).each(function() {
      li.addClass('twiddle');
      if($('span.selected', this).length == 0){
        $(this).hide();
      } else {
        li.addClass('twiddle-open');
        li.children('.toggle-handle').attr('aria-expanded', 'true');
      }
    });

    // attach the toggle behavior to the li tag
    li.children('.toggle-handle').click(function(e){
      // toggle the content
      $(this).attr('aria-expanded', $(this).attr('aria-expanded') === 'true' ? 'false' : 'true');
      $(this).parent('li').toggleClass('twiddle-open');
      $(this).parent('li').children('ul').slideToggle();
    });
  };
})(jQuery);
