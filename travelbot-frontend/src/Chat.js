import React, { Component } from 'react';
import MessageList from './MessageList';
import ChatForm from './ChatForm';

const WS_ADDRESS = "ws://localhost:5000/";

class Chat extends Component {
  constructor(props) {
    super(props);
    this.state = { messages: [] };
    this.handleMessage = this.handleMessage.bind(this);
  }

  componentDidMount() {
    this.socket  = new WebSocket(WS_ADDRESS);
    this.socket.onmessage = ({ data }) => {
      this.setState({ messages: [data, ...this.state.messages] });
    };
  }

  handleMessage(msg) {
    this.setState({ messages: [msg, ...this.state.messages] });
    this.socket.send(msg);
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
