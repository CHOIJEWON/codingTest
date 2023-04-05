matterNo1 = (n) => {
  let result = [];

  const nums = Array.from({ length: n }, (_, i) => i + 1);

  for (let i = 0; i < nums.length; i += 4) {
    result.push(nums[i + 2], nums[i + 3], ...nums.slice(i, i + 2));
  }

  return result.filter((obj) => obj !== undefined);
};

matterNo2 = (map) => {
  const rows = map.length;
  const cols = map[0].split(" ").length;

  const memo = new Array(rows).fill(0).map(() => new Array(cols).fill(0));

  for (let i = 0; i < rows; i++) {
    const values = map[i].split(" ");
    memo[i][0] = parseInt(values[0]) + (i > 0 ? memo[i - 1][0] : 0);
  }

  for (let j = 0; j < cols; j++) {
    const values = map[0].split(" ");
    memo[0][j] = parseInt(values[j]) + (j > 0 ? memo[0][j - 1] : 0);
  }

  for (let i = 1; i < rows; i++) {
    for (let j = 1; j < cols; j++) {
      const values = map[i].split(" ");
      const current = parseInt(values[j]);
      memo[i][j] = current + Math.max(memo[i - 1][j], memo[i][j - 1]);
    }
  }

  return memo[rows - 1][cols - 1];
};

matterNo3 = (sentence) => {
  const words = sentence.split(" ");

  if (words.length < 4 || words[0] === words[words.length - 1]) return false;

  const choices = new Set();
  choices.add(sentence);

  for (let i = 1; i < words.length - 1; i++) {
    for (let j = i + 1; j < words.length; j++) {
      const newWords = [...words];
      const temp = newWords[i];
      newWords[i] = newWords[j];
      newWords[j] = temp;

      const newSentence = newWords.join(" ");
      if (!choices.has(newSentence)) {
        choices.add(newSentence);
      }
    }
  }

  const choiceArray = Array.from(choices);
  return choiceArray.slice(0, 5);
};
