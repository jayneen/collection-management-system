$(document).ready(function () {

    const components = [
        { id: "#header", file: "components/header.html" },
        { id: "#navigation", file: "components/navigation.html" },
        { id: "#addNav", file: "components/addNav.html" },
        { id: "#viewNav", file: "components/viewNav.html" }
    ];

    // Create an array of component loading operations
    const loadingOperations = components.map(function (component) {

        // Skip components that don't exist on this page
        if ($(component.id).length === 0) {
            return $.Deferred().resolve().promise();
        }

        // Load the component and return its promise
        return $(component.id).load(component.file).promise();

    });

    // Wait until every component has finished loading
    $.when.apply($, loadingOperations).always(function () {

        // Display the page
        $("body").addClass("components-loaded");

    });

});