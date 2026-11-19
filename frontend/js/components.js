$(function () {
    $('[data-include]').map(function () {
        const $el = $(this);
        return $.get($el.data('include')).done(function (html) {
            $el.html(html);
        });
    })
});