import React, { Component } from 'react';
import MessageList from './MessageList';
import ChatForm from './ChatForm';

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
        <ChatForm handleMessage={this.handleMessage} />
      </div>
    );
  }
}

export default Chat;
