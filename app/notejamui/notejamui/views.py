from datetime import date
import md5

from flask import render_template, flash, request, redirect, url_for
from flask.ext.login import (login_user, login_required, logout_user,
current_user)
from flask.ext.mail import Message

from notejamui import app, login_manager, mail
from notejamui.forms import (SigninForm, SignupForm, NoteForm, PadForm,
                       DeleteForm, ChangePasswordForm, ForgotPasswordForm)

import requests 
import logging

logger = logging.getLogger(__name__)

@login_manager.user_loader
def load_user(user_id):
    logger.info("Inside load_user")
    user = requests.get('http://notejam-api-service:5001/api/user/<user_id>')
    return user

@app.route('/')
@login_required
def home():
    logger.info("Inside home")
    notes = requests.get('http://notejam-api-service:5001/api/notes')
    return render_template('notes/list.html', notes=notes)


@app.route('/notes/create/', methods=['GET', 'POST'])
@login_required
def create_note():
    #note_form = NoteForm(user=current_user, pad=request.args.get('pad'))
    note_form = NoteForm(user=current_user, pad=request.args.get('pad'))
    if note_form.validate_on_submit():
        note = Note(
            name=note_form.name.data,
            text=note_form.text.data,
            pad_id=note_form.pad.data,
            user=current_user
        )
        requests.post('http://notejam-api-service:5001/api/create_note/note')
        flash('Note is successfully created', 'success')
        return redirect(_get_note_success_url(note))  
    return render_template('notes/create.html', form=note_form)


@app.route('/notes/<int:note_id>/edit/', methods=['GET', 'POST'])
@login_required
def edit_note(note_id):
    note = requests.post('http://notejam-api-service:5001/api/_get_user_object_or_404/<int:note_id>,<Obj:current_user')
    note_form = NoteForm(user=current_user, obj=note)
    if note_form.validate_on_submit():
        note.name = note_form.name.data
        note.text = note_form.text.data
        note.pad_id = note_form.pad.data

        requests.post('http://notejam-api-service:5001/api/edit_note/<obj:note>')
        flash('Note is successfully updated', 'success')
        return redirect(_get_note_success_url(note))
    if note.pad:
        note_form.pad.data = note.pad.id  # XXX ?
    return render_template('notes/edit.html', form=note_form)


@app.route('/notes/<int:note_id>/')
@login_required
def view_note(note_id):
    note = requests.post('http://notejam-api-service:5001/api/get_note/<int:note, <obj:current_user>')
    return render_template('notes/view.html', note=note)


@app.route('/notes/<int:note_id>/delete/', methods=['GET', 'POST'])
@login_required
def delete_note(note_id):
    note = requests.post('http://notejam-api-service:5001/api/_get_user_object_or_404/<int:note_id>,<Obj:current_user')
    delete_form = DeleteForm()
    if request.method == 'POST':
        requests.post('http://notejam-api-service:5001/api/delete_note/<obj:note>')
        flash('Note is successfully deleted', 'success')
        if note.pad:
            return redirect(url_for('pad_notes', pad_id=note.pad.id))
        else:
            return redirect(url_for('home'))
    return render_template('notes/delete.html', note=note, form=delete_form)


@app.route('/pads/create/', methods=['GET', 'POST'])
@login_required
def create_pad():
    pad_form = PadForm()
    if pad_form.validate_on_submit():
        pad = Pad(
            name=pad_form.name.data,
            user=current_user
        )
        requests.post('http://notejam-api-service:5001/api/create_pad/<obj:pad>,<Obj:current_user')
        flash('Pad is successfully created', 'success')
        return redirect(url_for('home'))
    return render_template('pads/create.html', form=pad_form)


@app.route('/pads/<int:pad_id>/edit/', methods=['GET', 'POST'])
@login_required
def edit_pad(pad_id):
    pad = requests.post('http://notejam-api-service:5001/api/_get_user_object_or_404/<Obj:pad, int:pad_id>,<Obj:current_user')
    pad_form = PadForm(obj=pad)
    if pad_form.validate_on_submit():
        requests.post('http://notejam-api-service:5001/api/update_pad/<obj:pad>')
        flash('Pad is successfully updated', 'success')
        return redirect(url_for('pad_notes', pad_id=pad.id))
    return render_template('pads/edit.html', form=pad_form, pad=pad)


@app.route('/pads/<int:pad_id>/')
@login_required
def pad_notes(pad_id):
    notes = requests.post('http://notejam-api-service:5001/api/pad_notes/<int:pad_id>,<Obj:current_user')
    return render_template('pads/note_list.html', pad=notes.pad, notes=notes)


@app.route('/pads/<int:pad_id>/delete/', methods=['GET', 'POST'])
@login_required
def delete_pad(pad_id):
    pad = _requests.post('http://notejam-api-service:5001/api/_get_user_object_or_404/<Obj:pad, int:pad_id>,<Obj:current_user')
    delete_form = DeleteForm()
    if request.method == 'POST':
        requests.post('http://notejam-api-service:5001/api/delete_pad/<obj:pad>')
        flash('Note is successfully deleted', 'success')
        return redirect(url_for('home'))
    return render_template('pads/delete.html', pad=pad, form=delete_form)


# @TODO use macro for form fields in template
@app.route('/signin/', methods=['GET', 'POST'])
def signin():
    form = SigninForm()
    if form.validate_on_submit():
        email = form.email.data
        password = form.password.data
        auth_user = requests.post('http://notejam-api-service:5001/api/authenticate/<email, password>')
        if auth_user:
            login_user(auth_user)
            flash('You are signed in!', 'success')
            return redirect(url_for('home'))
        else:
            flash('Wrong email or password', 'error')
    return render_template('users/signin.html', form=form)


@app.route('/signout/')
def signout():
    logout_user()
    return redirect(url_for('signin'))


@app.route('/signup/', methods=['GET', 'POST'])
def signup():
    form = SignupForm()
    if form.validate_on_submit():
        email=form.email.data
        user = requests.post('http://notejam-api-service:5001/api/get_user/<email>')
        user.set_password(form.password.data)
        requests.post('http://notejam-api-service:5001/api/add_user/<Obj:user>')
        flash('Account is created. Now you can sign in.', 'success')
        return redirect(url_for('signin'))
    return render_template('users/signup.html', form=form)


@app.route('/settings/', methods=['GET', 'POST'])
@login_required
def account_settings():
    form = ChangePasswordForm(user=current_user)
    if form.validate_on_submit():
        current_user.set_password(form.new_password.data)
        requests.post('http://notejam-api-service:5001/api/update_user/<Obj:current_user>')
        flash("Your password is successfully changed.", 'success')
        return redirect(url_for('home'))
    return render_template('users/settings.html', form=form)


@app.route('/forgot-password/', methods=['GET', 'POST'])
def forgot_password():
    form = ForgotPasswordForm()
    if form.validate_on_submit():
        email = form.email.data
        user = requests.post('http://notejam-api-service:5001/api/get_user/<email>')
        new_password = _generate_password(user)
        user.set_password(new_password)
        requests.post('http://notejam-api-service:5001/api/update_user/<Obj:user>')
        message = Message(
            subject="Notejam password",
            body="Your new password is {}".format(new_password),
            sender="from@notejamapp.com",
            recipients=[user.email]
        )
        mail.send(message)        
        flash("Find new password in your inbox", 'success')
        return redirect(url_for('home'))
    return render_template('users/forgot_password.html', form=form)


# context processors and filters
@app.context_processor
def inject_user_pads():
    ''' inject list of user pads in template context '''
    if not current_user.is_anonymous():
        return dict(pads=current_user.pads.all())
    return dict(pads=[])


@app.template_filter('smart_date')
def smart_date_filter(updated_at):
    delta = date.today() - updated_at.date()
    if delta.days == 0:
        return 'Today at {}'.format(updated_at.strftime("%H:%M"))
    elif delta.days == 1:
        return 'Yesterday at {}'.format(updated_at.strftime("%H:%M"))
    elif 1 > delta.days > 4:
        return '{} days ago'.format(abs(delta.days))
    else:
        return updated_at.date()


# helper functions, @TODO move to helpers.py?
def _get_note_success_url(note):
    ''' get note success redirect url depends on note's pad '''
    if note.pad is None:
        return url_for('home')
    else:
        return url_for('pad_notes', pad_id=note.pad.id)


def _generate_password(user):
    ''' generate new user password '''
    m = md5.new()
    m.update(
        "{email}{secret}{date}".format(
            email=user.email,
            secret=app.secret_key,
            date=str(date.today())
        )
    )
    return m.hexdigest()[:8]
