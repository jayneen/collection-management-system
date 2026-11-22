$(function () {
    const type = new URLSearchParams(location.search).get('type');
    const cfg = ENTITIES[type];
    if (!cfg) { $('body').text('Unknown type: ' + type); return; }

    document.title = 'View ' + cfg.title;
    $('#pageTitle').text('View All ' + cfg.title);
    $('#search').attr('placeholder', `Search ${cfg.title.toLowerCase()}...`);

    // Header row from config
    const $head = $('<tr>');
    cfg.columns.forEach(c => $head.append($('<th>').text(c.label)));
    $head.append($('<th>').text('Actions'));
    $('#tbl thead').empty().append($head);

    let rows = [];

    function render(filter) {
        const f = (filter || '').toLowerCase();
        const $body = $('#tbl tbody').empty();
        rows.filter(r => !f || String(r[cfg.searchKey]).toLowerCase().includes(f))
            .forEach(r => {
                const $tr = $('<tr>');
                cfg.columns.forEach(c => $tr.append($('<td>').text(c.value(r))));
                $tr.append($('<td>').append(
                    $('<a class="btn btn-info btn-sm">View</a>').attr('href', cfg.viewUrl(r)), ' ',
                    $('<a class="btn btn-warning btn-sm">Edit</a>').attr('href', cfg.editUrl(r)), ' ',
                    $('<button class="btn btn-danger btn-sm del-btn">Delete</button>')
                        .attr('data-uid', r.UID)
                        .attr('data-name', r[cfg.nameKey])
                ));
                $body.append($tr);
            });
    }

    function load() {
        $.getJSON(cfg.endpoint)
            .done(data => { rows = data; render($('#search').val()); })
            .fail(xhr => console.error('Failed to load:', xhr.status, xhr.responseText));
    }


    load();

    $(document).on('input', '#search', function () { render(this.value); });

    $(document).on('click', '.del-btn', function () {
        $('#modalMessage').text(`Are you sure you want to delete ${$(this).data('name')}?`);
        $('#confirmDel').data('uid', $(this).data('uid'));
        $('#delModal').modal('show');
    });

    $(document).on('click', '#confirmDel', function () {
        $.ajax({ url: `${cfg.endpoint}/${encodeURIComponent($(this).data('uid'))}`, method: 'DELETE' })
            .done(function () { $('#delModal').modal('hide'); load(); })
            .fail(function (xhr) {
                $('#delMsg').html($('<div class="alert alert-warning">').text(xhr.responseJSON?.Error || 'Delete failed'));
            });
    });

});