document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('div.highlighter-rouge').forEach(function (block) {
        var button = document.createElement('button');
        button.className = 'copy-code-button';
        button.type = 'button';
        button.textContent = 'Copy';

        button.addEventListener('click', function () {
            var code = block.querySelector('pre.highlight');
            if (!code) return;

            navigator.clipboard.writeText(code.innerText).then(function () {
                button.textContent = 'Copied!';
                setTimeout(function () {
                    button.textContent = 'Copy';
                }, 2000);
            });
        });

        block.appendChild(button);
    });
});
