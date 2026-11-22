$(function () {
    const loads = $('[data-include]').map(function () {
        const $el = $(this);
        return $.get($el.data('include')).done(html => $el.html(html));
    }).get();

    window.componentsReady = $.when.apply($, loads).always(function () {
        $('body').addClass('components-loaded');
    });
});