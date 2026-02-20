---
name: convert-to-prog8
description: Describe when to use this prompt
agent: ask
---
Convert the selected code to Prog8.

If the context sent with this prompt is an entire file, stop and ask the user if they meant to convert the entire file, and if not, ask them to 1. select the code they want to convert, then 2. restart the conversion process.

Use the [prog8 to progb conversion guide](../PROG8_TO_PROGB_CONVERSION.md) to figure out how to convert code between the languages.

Output the code in a raw markdown code block.
