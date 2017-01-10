import React, { Component } from 'react';
import MessageList from './MessageList'

class ChatForm extends Component {
  constructor(props) {
    super(props);
    this.onSubmit = this.onSubmit.bind(this);
  }

  onSubmit(event) {
    debugger;
  }
  render() {
    return (
      <div className="Form">
        <form onSubmit={this.onSubmit}>
          <input type="text" />
          <button type="submit">Send</button>
        </form>
      </div>
    );
  }
}

class Chat extends Component {
  constructor(props) {
    super(props);
    this.state = { messages: ["hello there", "hi"] };

    this.handleMessage = this.handleMessage.bind(this);
  }

  handleMessage(msg) {
    this.setState({ messages: [msg, ...this.state.messages] });
  }

  render() {
    return (
      <div className="Chat">
        <MessageList messages={this.state.messages} />
        <ChatForm onSubmit={this.handleMessage} />
      </div>
    );
  }
}

export default Chat;
