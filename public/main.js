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
    return wordChain[wordChain.length - 1];
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
  
    return fetch('http://localhost:9292/chain', {
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
        return false;
      } else {
        emptyChip.classList.remove('grey');
        emptyChip.classList.add('green');
        return true;
      }
    })
    .catch((error) => {
      console.error('Error:', error);
      return false;
    });
  }

  // Function to handle the submission of a word
  async function handleSubmitWord() {
    const currentWordArr = getCurrentWordArr();

    // If the current word array is empty, return early
    if (currentWordArr.length === 0) {
      return;
    }

    const emptyChip = document.querySelector('.chip.grey');
    if (emptyChip) {

      const currentWord = currentWordArr.join("");

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
          }
        })
        .catch((error) => console.error('Error:', error));
        // Return here to prevent the creation of a new grey chip
        return;
      } else {
        // Validate the word
        const isValid = await validateWord(wordChain, emptyChip);
        if (isValid) {

          // Turn the grey chip green
          emptyChip.classList.remove('grey');
          emptyChip.classList.add('green');

          // Create a new grey chip
          const newChip = document.createElement('div');
          newChip.classList.add('chip', 'grey');
          document.getElementById('board-container').appendChild(newChip);
          wordChain.push([]);

          // Set the focus to the new chip
          newChip.focus();
        } else {
          // If the word is not valid, turn the chip red
          emptyChip.classList.remove('grey');
          emptyChip.classList.add('red');
        }
      }
    }
  }

  // Function to handle the deletion of a letter
function handleDeleteLetter(emptyChip) {
  const currentWordArr = getCurrentWordArr();

  if (emptyChip) {
    
    if (currentWordArr.length > 0) {
      emptyChip.textContent = emptyChip.textContent.slice(0, -1);
      currentWordArr.pop();
    } else {
      if (emptyChip.textContent === '' && wordChain.length > 1) {
        const greenChips = document.querySelectorAll('.chip.green');
        if (greenChips.length > 0) {
          const lastGreenChip = greenChips[greenChips.length - 1];
          lastGreenChip.parentNode.removeChild(lastGreenChip);
        }
        wordChain.pop();
        wordChain[wordChain.length - 1] = [];
      }
      return;
    }
  }
  const redChips = document.querySelectorAll('.chip.red');
  if (redChips.length > 0) {
    const lastRedChip = redChips[redChips.length - 1];
    // Turn the red chip back to grey
    lastRedChip.classList.remove('red');
    lastRedChip.classList.add('grey');
    lastRedChip.textContent = '';
    wordChain[wordChain.length - 1] = [];
  }

}

  // Event listeners for the keyboard buttons
  for (let i = 0; i < keys.length; i++) {
    keys[i].onclick = ({ target }) => {
      const letter = target.getAttribute("data-key");

      const emptyChip = document.querySelector('.chip.grey');
        
      if (emptyChip && letter !== "enter" && letter !== "del") {
        emptyChip.textContent += letter;
        updateWordChain(letter);
      }

      if (letter === "enter") {
        handleSubmitWord();
        return;
      }

      if (letter === "del") {
        handleDeleteLetter(emptyChip);
        return;
      }

    };
  }
});