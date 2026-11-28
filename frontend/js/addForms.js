const ADD_FORMS = {
    gameName: {
        title: 'Add a Game Name',
        endpoint: '/games/gamenames',
        arrays: true,                  // this route expects every value wrapped in an array
        submitLabel: 'Add Game Name',
        nameField: 'gameName',
        success: name => `Game name "${name}" has been added.`,
        fields: [
            { name: 'gameName', label: 'Game Name', type: 'text', suggestions: '/options/gamenames', placeholder: 'Enter a game name' },
            { name: 'upc', label: 'UPC', type: 'number', placeholder: 'Enter the UPC' },
            { name: 'releaseDate', label: 'Release Date', type: 'date' },
            { name: 'rating', label: 'Rating', type: 'select', optionsUrl: '/options/ratings' },
            { name: 'series', label: 'Series', type: 'multi', optionsUrl: '/options/series' },
            { name: 'genre', label: 'Genre', type: 'multi', optionsUrl: '/options/genres' },
            { name: 'consoles', label: 'Console', type: 'multi', optionsUrl: '/options/consoles' }
        ]
    },
    gameCopy: {
        title: 'Add a Game Copy',
        endpoint: '/games',
        submitLabel: 'Add Game',
        nameField: 'gameName',
        success: name => `A copy of "${name}" has been added.`,
        fields: [
            { name: 'gameName', label: 'Game Name', type: 'select', optionsUrl: '/options/gamenames' },
            { name: 'region', label: 'Region', type: 'text', suggestions: '/options/regions', placeholder: 'Enter a region' },
            { name: 'condition', label: 'Condition', type: 'select', optionsUrl: '/options/conditions' },
            { name: 'sealOrCIB', label: 'Seal or CIB', type: 'select', optionsUrl: '/options/sealorcibs' },
            { name: 'notes', label: 'Notes', type: 'textarea', placeholder: 'Enter notes here...' }
        ]
    },
    consoleCopy: {
        title: 'Add a Console Copy',
        endpoint: '/consoles',
        submitLabel: 'Add Console',
        nameField: 'modelName',
        success: name => `A copy of "${name}" has been added.`,
        fields: [
            { name: 'modelName', label: 'Console Model', type: 'select', optionsUrl: '/options/consoles' },
            { name: 'region', label: 'Region', type: 'text', suggestions: '/options/regions', placeholder: 'Enter a region' },
            { name: 'condition', label: 'Condition', type: 'select', optionsUrl: '/options/conditions' },
            { name: 'sealOrCIB', label: 'Seal or CIB', type: 'select', optionsUrl: '/options/sealorcibs' }
        ]
    },
    consoleModel: {
        title: 'Add a Console Model',
        endpoint: '/consoles/consolemodels',
        arrays: true,                  // like the game name form, this route gets every value in an array
        submitLabel: 'Add Console Model',
        nameField: 'modelName',
        success: name => `Console model "${name}" has been added.`,
        fields: [
            { name: 'modelName', label: 'Model Name', type: 'text', suggestions: '/options/consoles', placeholder: 'Enter a model name' },
            { name: 'consolePublisher', label: 'Console Publisher', type: 'text', suggestions: '/options/consolepublishers', placeholder: 'Enter a publisher' }
        ]
    }
};