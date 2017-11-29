$(() => {
  $(document).on('turbolinks:render, turbolinks:load', () => {

    // setTimeout(remove_alerts, 3000);
    // function remove_alerts() {
    //   $('.alert').fadeOut();
    // }

    $('a.freetext').click(function() {
      $(this).parents('.form-group').find(':input').each(function() {
        var $input = $(this);
        $input.toggle();
        // assure that only the visible field has the name attribute
        // set to avoid double submits
        if ($input.is(':visible')) {
          $input.attr('name', $input.data('name'));
        } else {
          $input.data('name', $input.attr('name'));
          $input.removeAttr('name');
        };
      });
    });
    $('a.freetext').click();


    $('#tree').treeview({
      data: $('#tree').data('tree'),
      enableLinks: true,
      levels: 1
    });
    $('#tree_expand_all').click(function () {
      $('#tree').treeview('expandAll');
    });
    $('#tree_collapse_all').click(function () {
      $('#tree').treeview('collapseAll');
    });
    $('#tree_delete_node').click(function (event) {
      event.preventDefault();
      event.stopPropagation();
      var nodes = $('#tree').treeview('getSelected');
      if (1 > nodes.length) {
        alert('Bitte wählen Sie ein Dokument zum löschen.')
        return;
      }
      if (!window.confirm("Wirklich löschen?")) {
        return;
      }
      var href = $(this).attr("href") + '/' + nodes[0].documentId;
      $.ajax(href, {
        method: "DELETE",
        async: false
      })
      location.reload();
    });
    $("#tree").on("click", "a", function (event) {
      event.preventDefault();
      var href = $(this).attr("href");
      if ('#' != href) {
        window.open(href);
      }
    });


  });
});
