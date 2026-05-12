## Represents the awaitable asynchronous operation.
@abstract
class_name Awaitable

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## Waits until this [Awaitable] is settled.[br]
## [br]
## [b]Note:[/b] This method must be called with the [code]await[/code] keyword.
@abstract
func wait(cancel: Cancel = null) -> Variant
