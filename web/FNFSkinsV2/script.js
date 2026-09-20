const copyButtons = document.querySelectorAll('.copy-button');

copyButtons.forEach((copyButton) => {
    copyButton.addEventListener('click', async () => {
        const loadstring = copyButton.parentElement.querySelector('.loadstring');

        try {
            await navigator.clipboard.writeText(loadstring.textContent.trim());
            copyButton.textContent = 'Copied';

            setTimeout(() => {
                copyButton.textContent = 'Copy to Clipboard';
            }, 1500);
        } catch (error) {
            copyButton.textContent = 'Could not copy';
        }
    });
});
