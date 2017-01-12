import React from 'react';

export default function (props) {
  const messageList = props.messages.map((msg, i) => {
    let string = msg.label;
    if (msg.user && props.thisUser.id === msg.user.id) {
      return <div key={i} className="message message-mine">{string}</div>;
    } else {
      return <div key={i} className="message">{string}</div>;
    }
  });

  return (
    <div className="Message-list">
      {messageList}
    </div>
  );
}
