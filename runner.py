"""Run Advent of Code challenges through a specified solver."""

from os import makedirs, path
import re
import subprocess
from sys import argv, stderr, exit

from requests import Session

session = Session()
session.headers['User-Agent'] = 'AOC runner by Joey <joe@reeshill.net>'


def main():
    if len(argv) < 3:
        print(
            f"Usage: aoc <daynum> <level> <program> [optional " "program args...]",
            file=stderr,
        )
        exit(1)
    if not argv[1].isnumeric():
        print(f"Error: day {argv[1]!r} is not a number.", file=stderr)
        exit(1)
    if not argv[2].isnumeric():
        print(f"Error: part {argv[2]!r} is not a number.", file=stderr)
        exit(1)

    solver = ["/bin/bash", "-i", "-c", " ".join(argv[3:])]
    puzzle_inp = AOCInput(int(argv[1]))

    with open(puzzle_inp.filename) as input_file:
        result = subprocess.run(
            solver, stdin=input_file, stdout=subprocess.PIPE, universal_newlines=True
        )

    if result.returncode:
        print(f"Error: exited with status {result.returncode}", file=stderr)
        exit(result.returncode)
    solution = result.stdout.strip().rpartition("\n")[2].strip()

    print("Your answer:", solution)
    print("Submitting...")
    print(puzzle_inp.answer(int(argv[2]), solution))


class AOCInput:
    url = "https://adventofcode.com/{year}/day/{day}/input"
    answer_url = "https://adventofcode.com/{year}/day/{day}/answer"

    @staticmethod
    def _join(*items):
        """Join a path relative to the parent directory of this file."""
        return path.join(path.dirname(path.abspath(__file__)), *items)

    def __init__(self, day, year="2022"):
        self.year = year
        self.day = day
        self._cookie_file = self._join("aoc-token.txt")
        self._session_cookie = None
        self._file = self._join("inputs", f"{self.year}-{self.day:02}.inp")
        self._loaded = path.exists(self._file)

    @property
    def filename(self):
        if not self._loaded:
            self._load()
        return self._file

    def _request_input(self):
        response = session.get(self._url(), cookies={"session": self._session})
        if response.ok:
            return response.text
        raise Exception("Getting input did not succeed!")

    @property
    def _session(self):
        if self._session_cookie is None:
            try:
                with open(self._cookie_file) as f:
                    self._session_cookie = f.read().strip()
            except FileNotFoundError:
                self._session_cookie = input("Enter session cookie: ").strip()
                if input("Save? [y/n] ").lower().startswith("y"):
                    with open(self._cookie_file, "w") as f:
                        f.write(self._session_cookie)
        return self._session_cookie

    def _url(self):
        return self.url.format(day=self.day, year=self.year)

    def _load(self):
        value = self._request_input()
        makedirs(path.dirname(self._file), exist_ok=True)
        with open(self._file, "w") as f:
            f.write(value)

    def _post_answer(self, part, answer):
        url = self.answer_url.format(year=self.year, day=self.day)
        return session.post(
            url,
            data={"answer": answer, "level": part},
            cookies={"session": self._session},
        ).text

    def answer(self, level, answer):
        response = self._post_answer(level, answer)

        wait = re.search(r"You have .+ left to wait", response)
        if wait is not None:
            return f"Too soon! {wait.group()}"
        elif "That's not the right answer" in response:
            return re.search(r"That's not the right answer[^.]*\.", response).group()
        elif "That's the right answer!" in response:
            return "Correct!"
        elif "You don't seem to be solving the right level" in response:
            return "Wrong level!"
        elif "Please don't repeatedly request this endpoint" in response:
            return "Puzzle still locked! (or wrong day)"
        elif "You're posting too much data." in response:
            return "Answer is too large (in bytes)."
        return "Unknown response:\n" + response


if __name__ == "__main__":
    main()
