# Airflow Environment Variables

Airflow requires some environment variables for the Docker setup.

## Fernet Key

`FERNET_KEY` is used by Airflow to encrypt sensitive values stored in its
metadata database, such as connection credentials.

Generate a Fernet key with Python:

```
pip install cryptography
```

```powershell
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

Store the generated key in the local `.env` file:

```env
FERNET_KEY=<generated_key>
```

Do not commit the real Fernet key to Git.

The `.env.example` file contains only a placeholder:

```env
FERNET_KEY=your_fernet_key_here
```

## Airflow UID

```env
AIRFLOW_UID=50000
```
