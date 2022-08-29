from notejamapi.notejamapi import app, db
from notejamapi.notejamapi.models import User, Note, Pad


@app.route('/user/<int:note_id>', methods=['GET'])
def get_user(user_id):
    return User.query.get(user_id)


@app.route('/get_notes/<int:user_id, Obj request>', methods=['GET'])
def get_notes(user_id, request):
    user = get_user(user_id)
    return (Note.query
                 .filter_by(user=user)
                 .order_by(_get_order_by(request.args.get('order')))
                 .all())

@app.route('/create_note/<Note:note>', methods=['GET'])
def create_note(note):
    db.session.add(note)
    db.session.commit()

@app.route('/create_note/<Note:note', methods=['GET'])
def edit_note(note):
    db.session.update(note)
    db.session.commit()
    
@app.route('/get_user_object_or_404/<Model:model, int:object_id>', methods=['POST'])
def get_user_object_or_404(model, object_id, user, code=404):
    ''' get an object by id and owner user or raise an abort '''
    result = model.query.filter_by(id=object_id, user=user).first()
    return result #or abort(code)

@app.route('/delete_note/<Note:note>', methods=['GET'])
def delete_note(note):
    db.session.delete(note)
    db.session.commit()

@app.route('/create_pad/<Pad:pad>', methods=['POST'])
def create_pad(pad):
    db.session.add(pad)
    db.session.commit()

@app.route('/edit_pad/<Pad:pad>', methods=['POST'])
def update_pad(pad):
    db.session.update(pad)
    db.session.commit()

@app.route('/pad_notes/<Model:model, int:object_id, Obj:user>, Obj:request', methods=['POST'])
def pad_notes(model, object_id, user, request):
    pad = model.query.filter_by(id=object_id, user=user).first()
    notes = (Note.query
                 .filter_by(user=user, pad=pad)
                 .order_by(_get_order_by(request.args.get('order')))
                 .all())
    return notes

@app.route('/delete_pad/<Pad:pad>', methods=['POST'])
def delete_pad(pad):
    db.session.delete(pad)
    db.session.commit()

@app.route('/add_user/<email, password>', methods=['GET'])
def authenticate(email, password):
    auth_user = User.authenticate(email, password)
    return auth_user

@app.route('/add_user/<User:user>', methods=['POST'])
def add_user(user):
    db.session.add(user)
    db.session.commit()

@app.route('/update_user/<User:user>', methods=['POST'])
def update_user(user):
    db.session.update(user)
    db.session.commit()

@app.route('/get_user/<email>', methods=['GET'])
def get_user_from_email(email):
    user = User.query.filter_by(email).first()
    return user

def _get_order_by(param='-updated_at'):
    ''' get model order param by string description '''
    return {
        'name': Note.name.asc(),
        '-name': Note.name.desc(),
        'updated_at': Note.updated_at.asc(),
        '-updated_at': Note.updated_at.desc(),
    }.get(param, Note.updated_at.desc())
