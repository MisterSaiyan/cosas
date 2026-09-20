const copyButton = document.querySelector('#copy-button');
const loadstring = document.querySelector('#loadstring');

copyButton.addEventListener('click', async () => {
    try {
        await navigator.clipboard.writeText(loadstring.textContent.trim());
        copyButton.textContent = 'Copiado';

        setTimeout(() => {
            copyButton.textContent = 'Copy to Clipboard';
        }, 1500);
    } catch (error) {
        copyButton.textContent = 'Failed to copy';
    }
});
