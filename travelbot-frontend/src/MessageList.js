import React from 'react';

export default function (props) {
  const messageList = props.messages.map((msg, i) => {
    return <li key={i}>{msg}</li>;
  });

  return (
    <div className="Message-list">
      <ul>{messageList}</ul>
    </div>
  );
}
