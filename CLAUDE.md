# Global rules

These apply to every project and every agent.

## Git

- Never add `Co-Authored-By`, `Generated with`, tool names, or any
  attribution to an assistant in commit messages, PR descriptions,
  code comments or documentation. The commit message describes the
  change and nothing else.
- Conventional commits: `type(scope): summary`.
  Types: feat, fix, refactor, test, docs, chore, perf, build, ci.
- Summary in the imperative, lowercase, no trailing period.
- Never push, never force-push, never rewrite history.
- Never commit secrets, `.env` files, or credentials.

## Language

- All code, comments, commit messages, identifiers, branch names and
  documentation are in **English**, always.
- Conversation with the human is in the language they are using.

## Comments

- Comment **why**, never **what**. If a comment restates the code,
  delete the comment.
- No section banners, no decorative separators, no changelog comments,
  no author or date tags.
- No commented-out code. Git remembers it.
- A comment is warranted for: a non-obvious business rule, a
  deliberate deviation from the standard, a workaround for an external
  bug (with a link), or a performance trade-off that looks wrong.
- Public API documentation blocks follow the language convention
  (JSDoc, PHPDoc) and are not covered by the above.

## Output

- No filler, no preamble, no summaries of what you are about to do.
- Report facts and unknowns. Never report success on unverified work.
- When blocked, ask. Do not guess and proceed.