function loadOptions(url) {
    return $.getJSON(url).then(
        items => items.filter(Boolean),
        err => { console.error(`Error loading ${url}:`, err); return []; }
    );
}

function makeDatalist(id, url) {
    const $list = $('<datalist>').attr('id', id);
    loadOptions(url).then(items => items.forEach(i => $list.append($('<option>').val(i))));
    return $list;
}

function buildField(f) {
    const id = 'f_' + f.name;
    const $group = $('<div class="form-group">')
        .append($('<label>').attr('for', id).text(f.label));

    if (f.type === 'select') {
        const $select = $('<select class="form-control">').attr({ id, name: f.name })
            .append($('<option value="">').text('Select ' + f.label.toLowerCase()));
        loadOptions(f.optionsUrl).then(items =>
            items.forEach(i => $select.append($('<option>').val(i).text(i))));
        $group.append($select);

    } else if (f.type === 'textarea') {
        $group.append($('<textarea class="form-control" rows="4">')
            .attr({ id, name: f.name, placeholder: f.placeholder || '' }));

    } else if (f.type === 'multi') {
        const listId = 'dl_' + f.name;
        const noun = f.noun || f.label.toLowerCase();
        const $rows = $('<div>').attr('id', id);

        function addRow() {
            const $row = $(`
                <div class="input-group mb-2">
                    <input type="text" class="form-control" autocomplete="off">
                    <div class="input-group-append">
                        <div class="input-group-text">
                            <input type="checkbox" class="add-more-toggle" title="Add/remove field">
                        </div>
                    </div>
                </div>`);
            $row.find('input[type=text]').attr({ list: listId, placeholder: 'Enter a ' + noun });
            $row.find('.add-more-toggle').on('change', function () {
                if (this.checked) {
                    addRow();
                } else {
                    $row.remove();
                    if (!$rows.children().length) addRow();   // always keep one row
                }
            });
            $rows.append($row);
        }
        addRow();
        $group.append($rows, makeDatalist(listId, f.optionsUrl));

    } else {   // text, number, date
        const $input = $('<input class="form-control">')
            .attr({ type: f.type, id, name: f.name, placeholder: f.placeholder || '' });
        $group.append($input);
        if (f.suggestions) {
            $input.attr('list', 'dl_' + f.name);
            $group.append(makeDatalist('dl_' + f.name, f.suggestions));
        }
    }
    return $group;
}

function readField(f) {
    const $el = $('#f_' + f.name);
    if (f.type === 'multi') {
        return $el.find('input[type=text]')
            .map(function () { return this.value.trim(); }).get()
            .filter(Boolean);
    }
    return $el.val();
}