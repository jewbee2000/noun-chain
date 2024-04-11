document.addEventListener("DOMContentLoaded", () => {

  // Variable declarations
  let wordChain = [[]];
  let startWord;
  let endWord;

  
  // Function calls to initialize the game
  getStartAndEndWords(); // Fetches the starting and ending words
  initializeBoard(startWord); // Initializes the game board

  // Select all the buttons in the keyboard
  const keys = document.querySelectorAll(".keyboard-row button");

  // This listens for key presses and clicks the corresponding button on the on-screen keyboard
  window.addEventListener('keydown', function(event) {
    var key = event.key.toLowerCase();

    // Handle the backspace key
    if (key === 'backspace') {
      key = 'del';
    }

    var button = Array.from(keys).find(k => k.textContent.trim().toLowerCase() === key);

    if (button) {
      button.click();
    }
  });

  // Function to fetch the starting and ending words
  function getStartAndEndWords() {
    // Replace this with logic to fetch the starting and ending words from the game table in the database
    startWord = "start";
    endWord = "end";
  }

  function getCurrentWordArr() {
    const solutionLength = wordChain.length;
    return wordChain[solutionLength - 1];
  }

  // Event listeners for the rules icon and close button
  var rulesIcon = document.querySelector('.rules-icon');
  var rulesPopup = document.getElementById('rules-popup');
  var close = document.getElementsByClassName('close')[0];

  rulesIcon.addEventListener('click', function() {
    rulesPopup.style.display = 'block';
  });

  close.onclick = function() {
    rulesPopup.style.display = 'none';
  }

  window.onclick = function(event) {
    if (event.target == rulesPopup) {
      rulesPopup.style.display = 'none';
    }
  }

  function updateWordChain(letter) {
    const currentWordArr = getCurrentWordArr();
    if (currentWordArr) {
      currentWordArr.push(letter);
    }
  }

  // Function to handle the submission of a word
  function handleSubmitWord() {
    const currentWordArr = getCurrentWordArr();

    const currentWord = currentWordArr.join("");

    const emptyChip = document.querySelector('.chip.grey');
    if (emptyChip) {
      // Turn the grey chip green
      emptyChip.classList.remove('grey');
      emptyChip.classList.add('green');

      if (currentWord === endWord) {
        // Delay the alert by a small amount of time to allow the browser to repaint the screen
        setTimeout(() => {
          window.alert("Congratulations!");
        }, 1);
        // Return here to prevent the creation of a new grey chip
        return;
      }

      // Create a new grey chip
      const newChip = document.createElement('div');
      newChip.classList.add('chip', 'grey');
      document.getElementById('board-container').appendChild(newChip);

      // Set the focus to the new chip
      newChip.focus();
    }

    wordChain.push([]);
  }

  // Initialize the game board
  function initializeBoard(startingWord) {
    const boardContainer = document.getElementById('board-container');

    // Create the starting chip
    const startingChip = document.createElement('div');
    startingChip.textContent = startingWord;
    startingChip.classList.add('chip', 'green');
    boardContainer.appendChild(startingChip);

    // Create the empty chip
    const emptyChip = document.createElement('div');
    emptyChip.classList.add('chip', 'grey');
    boardContainer.appendChild(emptyChip);

    // Set the focus to the empty chip
    emptyChip.focus();
  }

  // Function to handle the deletion of a letter
  function handleDeleteLetter() {
    const currentWordArr = getCurrentWordArr();
    const greyChip = document.querySelector('.chip.grey');

    // If the current word array has letters, remove the last letter
    if (currentWordArr.length > 0) {
      currentWordArr.pop();
    } else {
      // Only if the wordChain length is greater than 1
      if (greyChip && greyChip.textContent === '' && wordChain.length > 1) {
        const greenChips = document.querySelectorAll('.chip.green');
        if (greenChips.length > 0) {
          const lastGreenChip = greenChips[greenChips.length - 1];
          lastGreenChip.parentNode.removeChild(lastGreenChip);
          wordChain.pop();
        }
      }
    }
  }

  // Event listeners for the keyboard buttons
  for (let i = 0; i < keys.length; i++) {
    keys[i].onclick = ({ target }) => {
      const letter = target.getAttribute("data-key");

      const emptyChip = document.querySelector('.chip.grey');
      if (emptyChip && letter !== "enter" && letter !== "del") {
        emptyChip.textContent += letter;
        updateWordChain(letter); // Update the word chain with the new letter
      }

      if (letter === "enter") {
        handleSubmitWord();
        return;
      }

      if (letter === "del") {
        emptyChip.textContent = emptyChip.textContent.slice(0, -1);
        handleDeleteLetter();
        return;
      }
    };
  }
});