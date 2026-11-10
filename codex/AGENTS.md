# Global Coding Guidelines

## Instruction Priority
- Project-specific instructions override conflicting global instructions.
- Non-conflicting global instructions remain in effect.

## Language
- Always respond to the user in the language they use in their latest message, unless explicitly instructed otherwise.
- Use English for code, comments, filenames, directories, identifiers, and commit messages.
- Follow the existing language of documentation unless explicitly instructed otherwise.
- Do not translate existing names unless renaming is necessary for the task.

## Code Quality
- Prefer the simplest solution that fully satisfies the current requirements (KISS).
- Write code for actual requirements, not hypothetical future use cases (YAGNI).
- Optimize for readability and maintainability over cleverness or brevity.
- Keep control flow straightforward; prefer early returns over unnecessary nesting.
- Use descriptive, unambiguous names that communicate intent.
- Follow existing project conventions unless they conflict with explicit requirements.

## Performance
- Write efficient code with attention to runtime performance, memory usage, and resource consumption.
- Prefer efficient algorithms and data structures appropriate for the expected workload.
- Avoid unnecessary allocations, copies, computations, and redundant operations.
- Consider performance implications in frequently executed code paths.
- Do not sacrifice readability or introduce unnecessary complexity for insignificant performance gains.
- Optimize based on actual bottlenecks or clear, measurable benefits rather than speculation.

## Scope and Abstractions
- Make the smallest coherent change that solves the problem.
- Do not introduce abstractions, interfaces, configuration options, or extension points without a concrete current need.
- Avoid speculative generalization and premature optimization.
- Prefer direct implementations over unnecessary layers of indirection.
- Extract shared logic only when it meaningfully improves clarity or eliminates substantial duplication.
- Do not add speculative compatibility code or fallbacks for unsupported environments.
- Validate external input and handle failure modes required by the supported runtime contract.
- Do not refactor unrelated code or change unrelated behavior.
- Make necessary integration changes required for correctness, and explain any scope expansion.

## Comments
- Comments should explain non-obvious intent, constraints, or reasoning, not restate what the code does.
- Prefer self-explanatory code over comments.
- Keep comments concise and to the point while still making the intent clear. Do not include examples in comments.
- Remove or update comments that become inaccurate.

## Verification
- Check changes for correctness, unintended side effects, and unnecessary complexity.
- Run relevant tests or builds proportionate to the change, starting with the narrowest useful checks.
- Report what was verified and any checks that were not run.
- Never claim verification was performed unless it actually was.