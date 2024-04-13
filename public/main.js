document.addEventListener("DOMContentLoaded", () => {

  // Variable declarations
  let wordChain = [[]];
  let startWord;
  let endWord;

  // Initialize the game board
  function initializeBoard(startingWord) {
    console.log('Initializing board');
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

    // Add the starting word to the word chain
    wordChain[0] = startingWord.split('');
    wordChain.push([]);
  }

  // Function to fetch the starting and ending words
  function getStartAndEndWords() {
    // Fetch the game data when the page loads
    fetch('http://localhost:9292/game')
      .then(response => response.json())
      .then(game => {
        // Set the start and end words
        startWord = game.data.start_word;
        endWord = game.data.end_word;

        // Get the game details element
        var gameDetailsElement = document.getElementById('game-details');

        // Get today's date
        var today = new Date();

        // Format the date as "Month Day, Year"
        var formattedDate = today.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });

        // Set the game details
        var gameDetails = formattedDate + ": Get from <span class='chip green small-chip'>" + startWord + "</span> to <span class='chip green small-chip'>" + endWord + "</span>";
        // Update the content of the game details element
        gameDetailsElement.innerHTML = gameDetails;

        // Initialize the game board
        initializeBoard(startWord);
      })
      .catch(error => console.error('Error:', error));
  }
  
  // Function calls to initialize the game
  getStartAndEndWords(); // Fetches the starting and ending words

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

  function validateWord(wordChain, emptyChip) {
    // Get the last two words from the word chain
    const lastTwoWords = wordChain.slice(-2).map(wordArr => wordArr.join(''));
  
    fetch('http://localhost:9292/chain', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ d: lastTwoWords }),
    })
    .then(response => response.json())
    .then(data => {
      console.log('Server response:', data); // Log the server response
      if (data.status === 'fail') {
        emptyChip.classList.remove('grey');
        emptyChip.classList.add('red');
      } else {
        emptyChip.classList.remove('grey');
        emptyChip.classList.add('green');
      }
    })
    .catch((error) => console.error('Error:', error));
  }

  // Function to handle the submission of a word
  function handleSubmitWord() {
    const currentWordArr = getCurrentWordArr();

    const currentWord = currentWordArr.join("");

    const emptyChip = document.querySelector('.chip.grey');
    if (emptyChip) {

      validateWord(wordChain, emptyChip);

      if (currentWord === endWord) {
        // Turn the grey chip green
        emptyChip.classList.remove('grey');
        emptyChip.classList.add('green');

        // Post the solution to the server
        fetch('http://localhost:9292/soln', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ d: wordChain.flat() }),
        })
        .then(response => response.json())
        .then(data => {
          console.log('Status:', data.status); // Add this line
          if (data.status === 'success') {
            // Display user's stats
            console.log('Success:', data.data);
          } else {
            // Display 'invalid' in an alert
            window.alert('Invalid solution');
          }
        })
        .catch((error) => console.error('Error:', error));
        // Return here to prevent the creation of a new grey chip
        return;
      }
      else {
        validateWord(wordChain);
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