local Message = {}

export type MessageWindowProps = {
	maxMessages: number?,
	[string]: any,
}

export type MessageProps = {
	TextColor3: Color3,
	duration: number,
	soundInfoKey: string?,
	strokeThickness: number?,
	[string]: any,
}
export type Message = {
	id: string,
	message: string,
	count: number,
	props: MessageProps,
}

return Message
